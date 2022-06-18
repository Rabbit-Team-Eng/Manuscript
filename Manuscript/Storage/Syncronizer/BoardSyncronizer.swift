//
//  BoardSyncronizer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import CoreData
import Combine

class BoardSyncronizer: DataSyncronizer {
    
    typealias Model = BoardBusinessModel
    
    private let coreDataStack: CoreDataStack
    private var tokens: Set<AnyCancellable> = []
    private let startupUtils: StartupUtils
    private let boardCoreDataManager: BoardCoreDataManager
    private let boardService: BoardService

    init(coreDataStack: CoreDataStack, startupUtils: StartupUtils, boardCoreDataManager: BoardCoreDataManager, boardService: BoardService) {
        self.coreDataStack = coreDataStack
        self.startupUtils = startupUtils
        self.boardCoreDataManager = boardCoreDataManager
        self.boardService = boardService
    }
    
    func syncronize(items: [ComparatorResult<BoardBusinessModel>], completion: @escaping () -> Void) {
        
        let group = DispatchGroup()

        
        items.filter { $0.target == .local && $0.operation == .insertion }.map { $0.businessObject }.forEach { boardBusinessModelToBeInserted in
            insertIntoLocal(item: boardBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .local && $0.operation == .update }.map { $0.businessObject }.forEach { boardBusinessModelToBeUpdated in
            updateIntoLocal(item: boardBusinessModelToBeUpdated)
        }
        
        items.filter { $0.target == .local && $0.operation == .removal }.map { $0.businessObject }.forEach { boardBusinessModelToBeDeleted in
            deleteIntoLocal(item: boardBusinessModelToBeDeleted)
        }
        
        items.filter { $0.target == .server && $0.operation == .insertion }.map { $0.businessObject }.forEach { boardBusinessModelToBeInserted in
            group.enter()
            insertIntoServer(item: boardBusinessModelToBeInserted) {
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
            completion()
        }
    }
    
    private func insertIntoLocal(item: BoardBusinessModel) {
        boardCoreDataManager.insertIntoLocalOnBackgroundThread(item: item)
    }
    
    private func updateIntoLocal(item: BoardBusinessModel) {
        boardCoreDataManager.updateIntoLocalInBackgrooundThread(item: item)
    }
    
    private func deleteIntoLocal(item: BoardBusinessModel) {
        boardCoreDataManager.deleteInLocalOnBackgroundThread(item: item)
    }
    
    private func insertIntoServer(item: BoardBusinessModel, completion: @escaping () -> Void) {
        boardService.createNewBoard(requestBody: BoardRequest(workspaceId: Int(item.ownerWorkspaceId), assetUrl: item.assetUrl, title: item.title))
            .sink { completion in } receiveValue: { [weak self] boardResponse in
                
                guard let self = self, let coreDataId = item.coreDataId else { return }
                let context = self.coreDataStack.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let boardToBeUpdated = try? context.existingObject(with: coreDataId) as? BoardEntity {
                        boardToBeUpdated.remoteId = Int64(boardResponse.id)
                        boardToBeUpdated.lastModifiedDate = boardResponse.lastModifiedDate
                        boardToBeUpdated.isInitiallySynced = true
                        do {
                            try context.save()
                            completion()
                        } catch {
                            fatalError()
                        }
                    }
                }
            }
            .store(in: &tokens)

    }
    
    private func updateIntoServer(item: BoardBusinessModel) {
        
    }
    
    private func deleteIntoServer(item: BoardBusinessModel) {
        
    }
    
    deinit {
        print("DEALLOC -> BoardSyncronizer")
    }
    
}
