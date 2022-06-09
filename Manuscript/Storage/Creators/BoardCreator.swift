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
    
    private var tokens: Set<AnyCancellable> = []
    
    init(boardService: BoardService, database: CoreDataStack) {
        self.boardService = boardService
        self.database = database
    }
    
    func createNewBoard(board: BoardBusinessModel, completion: @escaping () -> Void) {
        
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let boardEntity = BoardEntity(context: context)
            boardEntity.assetUrl = board.assetUrl
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
                        boardToBeUpdated.remoteId = Int32(boardResponse.id)
                        boardToBeUpdated.lastModifiedDate = boardResponse.lastModifiedDate
                        boardToBeUpdated.isInitiallySynced = true
                        do {
                            try context.save()
                            self.notify()
                        } catch {
                            fatalError()
                        }
                    }
                }
            }
            .store(in: &self.tokens)

    }
    
    private func notify() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("BoardDidCreatedAndSyncedWithServer"), object: nil)
        }
    }
}
