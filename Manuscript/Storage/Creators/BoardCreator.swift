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
    
    func removeBoard(board: BoardBusinessModel, databaseCompletion: @escaping () -> Void, serverCompletion: @escaping () -> Void) {
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
                do {
                    try context.save()
                    databaseCompletion()
                    removeBoardInServer(board: board) { 
                        serverCompletion()
                    }
                    
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    private func removeBoardInServer(board: BoardBusinessModel, serverCompletion: @escaping () -> Void) {
        boardService.deleteBoardById(boardId: board.remoteId)
            .sink { completion in } receiveValue: { statusCode in

                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let coreDataId = board.coreDataId, let boardToBeRemoved = try? context.existingObject(with: coreDataId) as? BoardEntity {
                        context.delete(boardToBeRemoved)

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
}
