//
//  DatabaseManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/7/22.
//

import Combine
import CoreData

class WorkspaceCoreDataManager {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func insertIntoLocalAsync(item: WorkspaceBusinessModel, completion: @escaping () -> Void) {

        let context = self.coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.perform {
            let workspaceCoreDataEntity = WorkspaceEntity(context: context)
            workspaceCoreDataEntity.remoteId = item.remoteId
            workspaceCoreDataEntity.title = item.title
            workspaceCoreDataEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
            workspaceCoreDataEntity.isInitiallySynced = item.isInitiallySynced
            workspaceCoreDataEntity.isPendingDeletionOnTheServer = item.isPendingDeletionOnTheServer
            workspaceCoreDataEntity.mainDescription = item.mainDescription
            workspaceCoreDataEntity.sharingEnabled = item.sharingEnabled
            do {
                try context.save()
                completion()
            } catch {
                fatalError()
            }
        }
    }
    
    
}

protocol DataSyncronizer {
    associatedtype Model where Model : BusinessModelProtocol
    
    func syncronize(items: [ComparatorResult<Model>])
    
    func insertIntoLocal(item: Model)
    func updateIntoLocal(item: Model)
    func deleteIntoLocal(item: Model)
    
    func insertIntoServer(item: Model)
    func updateIntoServer(item: Model)
    func deleteIntoServer(item: Model)
}

class WorkspaceSyncronizer: DataSyncronizer {
    
    typealias Model = WorkspaceBusinessModel
    
    private let coreDataStack: CoreDataStack
    private let workspaceService: WorkspaceService
    private var tokens: Set<AnyCancellable> = []
    private let startupUtils: StartupUtils

    init(coreDataStack: CoreDataStack, workspaceService: WorkspaceService, startupUtils: StartupUtils) {
        self.coreDataStack = coreDataStack
        self.workspaceService = workspaceService
        self.startupUtils = startupUtils
    }
    
    func syncronize(items: [ComparatorResult<Model>]) {
        items.filter { $0.target == .local && $0.operation == .insertion }.map { $0.businessObject }.forEach { workspaceBusinessModelToBeInserted in
            insertIntoLocal(item: workspaceBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .local && $0.operation == .update }.map { $0.businessObject }.forEach { workspaceBusinessModelToBeInserted in
            updateIntoLocal(item: workspaceBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .local && $0.operation == .removal }.map { $0.businessObject }.forEach { workspaceBusinessModelToBeInserted in
            deleteIntoLocal(item: workspaceBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .server && $0.operation == .insertion }.map { $0.businessObject }.forEach { workspaceBusinessModelToBeInserted in
            insertIntoServer(item: workspaceBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .server && $0.operation == .update }.map { $0.businessObject }.forEach { workspaceBusinessModelToBeInserted in
            updateIntoServer(item: workspaceBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .server && $0.operation == .removal }.map { $0.businessObject }.forEach { workspaceBusinessModelToBeInserted in

        }
    }


    
    func insertIntoLocal(item: WorkspaceBusinessModel) {
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            let workspaceCoreDataEntity = WorkspaceEntity(context: context)
            workspaceCoreDataEntity.remoteId = item.remoteId
            workspaceCoreDataEntity.title = item.title
            workspaceCoreDataEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
            workspaceCoreDataEntity.isInitiallySynced = true
            workspaceCoreDataEntity.isPendingDeletionOnTheServer = false
            workspaceCoreDataEntity.mainDescription = item.mainDescription
            workspaceCoreDataEntity.sharingEnabled = item.sharingEnabled
            do {
                try context.save()
            } catch {
                fatalError()
            }
        }
    }
    
    func updateIntoLocal(item: WorkspaceBusinessModel) {
        
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
           
            if let objectId = item.coreDataId, let workspaceCoreDataEntity = try? context.existingObject(with: objectId) as? WorkspaceEntity {
                workspaceCoreDataEntity.title = item.title
                workspaceCoreDataEntity.mainDescription = item.mainDescription
                workspaceCoreDataEntity.sharingEnabled = item.sharingEnabled
                workspaceCoreDataEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
                do {
                    try context.save()
                } catch {
                    fatalError("updateIntoLocal")
                }
            }
        }
        
    }
    
    func deleteIntoLocal(item: WorkspaceBusinessModel) {
        
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            if let objectId = item.coreDataId, let workspaceCoreDataEntity = try? context.existingObject(with: objectId) as? WorkspaceEntity {
                context.delete(workspaceCoreDataEntity)
                do {
                    try context.save()
                } catch {
                    fatalError()
                }
            }
        }
        


    }
    
    func insertIntoServer(item: WorkspaceBusinessModel) {
        workspaceService.createNewWorkspace(accessToken: startupUtils.getAccessToken(),
                                            requestBody: WorkspaceRequest(title: item.title, description: item.mainDescription ?? "",
                                               shareEnabled: false))
        .receive(on: DispatchQueue.global(qos: .userInitiated))
        .sink { completion in } receiveValue: { [weak self] workspaceResponse in
            guard let self = self, let coreDataId = item.coreDataId else { return }
            let context = self.coreDataStack.databaseContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true

            context.performAndWait {
                if let worskaceToBeUpdated = try? context.existingObject(with: coreDataId) as? WorkspaceEntity {
                    worskaceToBeUpdated.remoteId = Int32(workspaceResponse.id)
                    worskaceToBeUpdated.lastModifiedDate = workspaceResponse.lastModifiedDate
                    worskaceToBeUpdated.isInitiallySynced = true
                    do {
                        try context.save()
                    } catch {
                        fatalError()
                    }
                }
            }
            
        }
        .store(in: &tokens)
    }
    
    func updateIntoServer(item: WorkspaceBusinessModel) {
        workspaceService.updateWorkspaceById(accessToken: startupUtils.getAccessToken(),
                                                workspaceId: "\(item.remoteId)", body: WorkspaceRequest(title: item.title,
                                                                                                        description: item.mainDescription ?? "",
                                                                                                        shareEnabled: item.sharingEnabled))
        .receive(on: DispatchQueue.global(qos: .userInitiated))
        .sink { completion in } receiveValue: { [weak self] workspaceResponse in
            guard let self = self, let coreDataId = item.coreDataId else { return }
            let context = self.coreDataStack.databaseContainer.newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true

            context.performAndWait {
                if let worskaceToBeUpdated = try? context.existingObject(with: coreDataId) as? WorkspaceEntity {
                    worskaceToBeUpdated.lastModifiedDate = workspaceResponse.lastModifiedDate
                    do {
                        try context.save()
                    } catch {
                        fatalError()
                    }
                }
            }
            
        }
        .store(in: &tokens)
    }
    
    func deleteIntoServer(item: WorkspaceBusinessModel) {
        
    }
    
}

class BoardSyncronizer: DataSyncronizer {
    
    private let coreDataStack: CoreDataStack
    private var tokens: Set<AnyCancellable> = []
    private let startupUtils: StartupUtils

    init(coreDataStack: CoreDataStack, startupUtils: StartupUtils) {
        self.coreDataStack = coreDataStack
        self.startupUtils = startupUtils
    }

    
    func syncronize(items: [ComparatorResult<BoardBusinessModel>]) {
        items.filter { $0.target == .local && $0.operation == .insertion }.map { $0.businessObject }.forEach { boardBusinessModelToBeInserted in
            insertIntoLocal(item: boardBusinessModelToBeInserted)
        }
        
        items.filter { $0.target == .local && $0.operation == .update }.map { $0.businessObject }.forEach { boardBusinessModelToBeUpdated in
            updateIntoLocal(item: boardBusinessModelToBeUpdated)
        }
        
        items.filter { $0.target == .local && $0.operation == .removal }.map { $0.businessObject }.forEach { boardBusinessModelToBeDeleted in
            deleteIntoLocal(item: boardBusinessModelToBeDeleted)
        }
    }
    
    func insertIntoLocal(item: BoardBusinessModel) {
        let context = coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            let boardCoreDataEntity = BoardEntity(context: context)
            boardCoreDataEntity.remoteId = item.remoteId
            boardCoreDataEntity.title = item.title
            boardCoreDataEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: item.lastModifiedDate)
            boardCoreDataEntity.assetUrl = item.assetUrl
            boardCoreDataEntity.isPendingDeletionOnTheServer = item.isPendingDeletionOnTheServer
            boardCoreDataEntity.isInitiallySynced = item.isInitiallySynced
            boardCoreDataEntity.ownerWorkspaceId = item.ownerWorkspaceId
            do {
                try context.save()
            } catch {
                fatalError()
            }
        
        }
    }
    
    func updateIntoLocal(item: BoardBusinessModel) {
        
    }
    
    func deleteIntoLocal(item: BoardBusinessModel) {
        
    }
    
    func insertIntoServer(item: BoardBusinessModel) {
        
    }
    
    func updateIntoServer(item: BoardBusinessModel) {
        
    }
    
    func deleteIntoServer(item: BoardBusinessModel) {
        
    }
    
    typealias Model = BoardBusinessModel
    
    
}
