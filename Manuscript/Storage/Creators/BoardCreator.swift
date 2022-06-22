//
//  BoardCreator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/7/22.
//

import CoreData
import Combine


class BoardCreator {
    
    private let boardService: BoardService
    private let database: CoreDataStack
    private let signalRManager: SignalRManager
    private let dataProvider: DataProvider

    private var tokens: Set<AnyCancellable> = []
    
    init(boardService: BoardService, database: CoreDataStack, signalRManager: SignalRManager, dataProvider: DataProvider) {
        self.boardService = boardService
        self.signalRManager = signalRManager
        self.database = database
        self.dataProvider = dataProvider
    }
    
    func createBoard(board: BoardBusinessModel, databaseCompletion: @escaping () -> Void, serverCompletion: @escaping () -> Void) {
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let boardEntity = BoardEntity(context: context)
            boardEntity.assetUrl = board.assetUrl
            boardEntity.mainDescription = board.detailDescription
            boardEntity.isInitiallySynced = board.isInitiallySynced
            boardEntity.isPendingDeletionOnTheServer = board.isPendingDeletionOnTheServer
            boardEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: board.lastModifiedDate)
            boardEntity.ownerWorkspaceId = board.ownerWorkspaceId
            boardEntity.remoteId = board.remoteId
            boardEntity.title = board.title
            
            let workspacesFetchRequest: NSFetchRequest<WorkspaceEntity> = NSFetchRequest(entityName: "WorkspaceEntity")
            workspacesFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(board.ownerWorkspaceId))")
            
            do {
                let workspace: [WorkspaceEntity] = try context.fetch(workspacesFetchRequest)
                let worskpaceEntity = workspace.first!
                worskpaceEntity.addToBoards(boardEntity)
                try context.save()
                databaseCompletion()
                self.createBoardInServer(item: board, coreDataId: boardEntity.objectID) {
                    serverCompletion()
                }
            } catch {
                fatalError()
            }
        }
    }
    
    private func createBoardInServer(item: BoardBusinessModel, coreDataId: NSManagedObjectID?, serverCompletion: @escaping () -> Void) {
        
        boardService.createNewBoard(requestBody: BoardRequest(workspaceId: Int(item.ownerWorkspaceId), assetUrl: item.assetUrl, title: item.title))
            .sink { completion in } receiveValue: { [weak self] boardResponse in
                
                guard let self = self, let coreDataId = coreDataId else { return }
                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let boardToBeUpdated = try? context.existingObject(with: coreDataId) as? BoardEntity {
                        boardToBeUpdated.remoteId = Int64(boardResponse.id)
                        boardToBeUpdated.lastModifiedDate = boardResponse.lastModifiedDate
                        boardToBeUpdated.isInitiallySynced = true
                        do {
                            try context.save()
                            serverCompletion()
                            
                        } catch {
                            fatalError()
                        }
                    }
                }
            }
            .store(in: &self.tokens)
    }
    
    @available(*, deprecated, message: "Use createBoard with two completions instead.")
    func createNewBoard(board: BoardBusinessModel, completion: @escaping () -> Void) {
        
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let boardEntity = BoardEntity(context: context)
            boardEntity.assetUrl = board.assetUrl
            boardEntity.mainDescription = board.detailDescription
            boardEntity.isInitiallySynced = board.isInitiallySynced
            boardEntity.isPendingDeletionOnTheServer = board.isPendingDeletionOnTheServer
            boardEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: board.lastModifiedDate)
            boardEntity.ownerWorkspaceId = board.ownerWorkspaceId
            boardEntity.remoteId = board.remoteId
            boardEntity.title = board.title
            
            let workspacesFetchRequest: NSFetchRequest<WorkspaceEntity> = NSFetchRequest(entityName: "WorkspaceEntity")
            workspacesFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(board.ownerWorkspaceId))")
            
            do {
                let workspace: [WorkspaceEntity] = try context.fetch(workspacesFetchRequest)
                let worskpaceEntity = workspace.first!
                worskpaceEntity.addToBoards(boardEntity)
                try context.save()
                self.insertIntoServer(item: board, coreDataId: boardEntity.objectID)
                completion()
            } catch {
                fatalError()
            }
        }
    }
    
    @available(*, deprecated, message: "Use createBoardInServer with a completion instead.")
    private func insertIntoServer(item: BoardBusinessModel, coreDataId: NSManagedObjectID?) {
        
        boardService.createNewBoard(requestBody: BoardRequest(workspaceId: Int(item.ownerWorkspaceId), assetUrl: item.assetUrl, title: item.title))
            .sink { completion in } receiveValue: { [weak self] boardResponse in
                
                guard let self = self, let coreDataId = coreDataId else { return }
                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let boardToBeUpdated = try? context.existingObject(with: coreDataId) as? BoardEntity {
                        boardToBeUpdated.remoteId = Int64(boardResponse.id)
                        boardToBeUpdated.lastModifiedDate = boardResponse.lastModifiedDate
                        boardToBeUpdated.isInitiallySynced = true
                        do {
                            try context.save()
                            let currentMembers = self.dataProvider.fetchWorkspace(thread: .background, id: "\(boardResponse.workspaceId)").members?.compactMap { $0.remoteId }
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("BoardDidCreatedAndSyncedWithServer"), object: nil)
                                self.signalRManager.broadcastMessage(enity: "board", id: boardResponse.id, action: "create", members: currentMembers!)
                            }
                            
                        } catch {
                            fatalError()
                        }
                    }
                }
            }
            .store(in: &self.tokens)
    }
    
    func editBoard(board: BoardBusinessModel, databaseCompletion: @escaping () -> Void, serverCompletion: @escaping () -> Void) {
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait { [weak self] in guard let self = self else { return }
            if let coreDataId = board.coreDataId, let boardToBeUpdated = try? context.existingObject(with: coreDataId) as? BoardEntity {
                boardToBeUpdated.title = board.title
                boardToBeUpdated.assetUrl = board.assetUrl
                do {
                    try context.save()
                    databaseCompletion()
                    self.editBoardInServer(board: board) {
                        serverCompletion()
                    }
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    private func editBoardInServer(board: BoardBusinessModel, serverCompletion: @escaping () -> Void) {
        
        boardService.updateBoardById(requestBody: BoardRequest(workspaceId: Int(board.ownerWorkspaceId), assetUrl: board.assetUrl, title: board.title), boardId: board.remoteId)
            .sink { completion in } receiveValue: { [weak self] boardResponse  in guard let self = self else { return }
                
                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let coreDataId = board.coreDataId, let boardToBeUpdated = try? context.existingObject(with: coreDataId) as? BoardEntity {
                        boardToBeUpdated.lastModifiedDate = boardResponse.lastModifiedDate
                        do {
                            try context.save()
                            serverCompletion()
                        } catch {
                            fatalError()
                        }
                    }
                }
            }
            .store(in: &tokens)
    }
    
    @available(*, deprecated, message: "Use editBoard with two completions instead.")
    func editBoard(board: BoardBusinessModel, completion: @escaping () -> Void) {
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait { [weak self] in guard let self = self else { return }
            if let coreDataId = board.coreDataId, let boardToBeUpdated = try? context.existingObject(with: coreDataId) as? BoardEntity {
                boardToBeUpdated.title = board.title
                boardToBeUpdated.assetUrl = board.assetUrl
                completion()
                self.editBoardInServer(worskapceId: board.ownerWorkspaceId, assetUrl: board.assetUrl, title: board.title, boardId: board.remoteId, coreDataId: board.coreDataId)
                do {
                    try context.save()
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    @available(*, deprecated, message: "Use editBoardInServer with a completion instead.")
    private func editBoardInServer(worskapceId: Int64, assetUrl: String, title: String, boardId: Int64, coreDataId: NSManagedObjectID?) {
        boardService.updateBoardById(requestBody: BoardRequest(workspaceId: Int(worskapceId), assetUrl: assetUrl, title: title), boardId: boardId)
            .sink { completion in } receiveValue: { [weak self] boardResponse  in guard let self = self else { return }
                
                
                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let coreDataId = coreDataId, let boardToBeUpdated = try? context.existingObject(with: coreDataId) as? BoardEntity {
                        boardToBeUpdated.lastModifiedDate = boardResponse.lastModifiedDate
                        do {
                            try context.save()
                            let currentMembers = self.dataProvider.fetchWorkspace(thread: .background, id: "\(boardResponse.workspaceId)").members?.compactMap { $0.remoteId }

                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("BoardDidCreatedAndSyncedWithServer"), object: nil)
                                self.signalRManager.broadcastMessage(enity: "board", id: boardResponse.id, action: "create", members: currentMembers!)
                            }
                        } catch {
                            fatalError()
                        }
                    }
                }
                
                
            }
            .store(in: &tokens)
    }
    
    func removeBoard(board: BoardBusinessModel, completion: @escaping () -> Void) {
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            if let coreDataId = board.coreDataId, let boardToBeRemoved = try? context.existingObject(with: coreDataId) as? BoardEntity {
                boardToBeRemoved.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: board.lastModifiedDate)
                boardToBeRemoved.isPendingDeletionOnTheServer = board.isPendingDeletionOnTheServer
                
                boardToBeRemoved.tasks?.forEach({ boardTaskEntity in
                    if let task = boardTaskEntity as? TaskEntity {
                        task.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: board.lastModifiedDate)
                        task.isPendingDeletionOnTheServer = board.isPendingDeletionOnTheServer
                    }
                })
                completion()
                do {
                    try context.save()
                    self.removeFromServer(boardId: board.remoteId, ownerWorkspaceId: board.ownerWorkspaceId, coreDataId: coreDataId)
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    private func removeFromServer(boardId: Int64, ownerWorkspaceId: Int64, coreDataId: NSManagedObjectID?) {
        boardService.deleteBoardById(boardId: boardId)
            .sink { completion in } receiveValue: { statusCode in

                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let coreDataId = coreDataId, let boardToBeRemoved = try? context.existingObject(with: coreDataId) as? BoardEntity {
                       
                        context.delete(boardToBeRemoved)
                        let currentMembers = self.dataProvider.fetchWorkspace(thread: .background, id: "\(ownerWorkspaceId)").members?.compactMap { $0.remoteId }

                        do {
                            try context.save()
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("CloudSyncDidFinish"), object: nil)
                                self.signalRManager.broadcastMessage(enity: "board", id: Int(boardId), action: "create", members: currentMembers!)
                            }
                        } catch {
                            fatalError()
                        }
                    }
                }
                
                
                
            }
            .store(in: &tokens)

    }
    

}
