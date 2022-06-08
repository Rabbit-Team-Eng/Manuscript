//
//  BoardCreator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/7/22.
//

import CoreData

struct BoardCreator {
    
    private let boardService: BoardService
    private let database: CoreDataStack
    
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
                completion()
            } catch {
                fatalError()
            }
        }
    }
}
