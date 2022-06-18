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

    private var tokens: Set<AnyCancellable> = []
    
    init(boardService: BoardService, database: CoreDataStack, signalRManager: SignalRManager) {
        self.boardService = boardService
        self.signalRManager = signalRManager
        self.database = database
    }
    
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
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("BoardDidCreatedAndSyncedWithServer"), object: nil)
                                self.signalRManager.broadcastMessage(enity: "board", id: boardResponse.id, action: "create", members: ["88b297bf-e308-4170-bc1c-8df74108d7e7"])
                            }
                            
                        } catch {
                            fatalError()
                        }
                    }
                }
            }
            .store(in: &self.tokens)
    }
    
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
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("BoardDidCreatedAndSyncedWithServer"), object: nil)
                                self.signalRManager.broadcastMessage(enity: "board", id: boardResponse.id, action: "create", members: ["88b297bf-e308-4170-bc1c-8df74108d7e7"])
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
                    self.removeFromServer(boardId: board.remoteId, coreDataId: coreDataId)
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    private func removeFromServer(boardId: Int64, coreDataId: NSManagedObjectID?) {
        boardService.deleteBoardById(boardId: boardId)
            .sink { completion in } receiveValue: { statusCode in

                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let coreDataId = coreDataId, let boardToBeRemoved = try? context.existingObject(with: coreDataId) as? BoardEntity {
                       
                        context.delete(boardToBeRemoved)
                        do {
                            try context.save()
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("CloudSyncDidFinish"), object: nil)
                                self.signalRManager.broadcastMessage(enity: "board", id: Int(boardId), action: "create", members: ["88b297bf-e308-4170-bc1c-8df74108d7e7"])
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
