//
//  WorkspaceSyncronizer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import CoreData
import Combine

class WorkspaceSyncronizer: DataSyncronizer {
    
    typealias Model = WorkspaceBusinessModel
    
    private let coreDataStack: CoreDataStack
    private let workspaceService: WorkspaceService
    private var tokens: Set<AnyCancellable> = []
    private let startupUtils: StartupUtils
    private let workspaceCoreDataManager: WorkspaceCoreDataManager

    init(coreDataStack: CoreDataStack, workspaceService: WorkspaceService, startupUtils: StartupUtils, workspaceCoreDataManager: WorkspaceCoreDataManager) {
        self.coreDataStack = coreDataStack
        self.workspaceService = workspaceService
        self.startupUtils = startupUtils
        self.workspaceCoreDataManager = workspaceCoreDataManager
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


    
    private func insertIntoLocal(item: WorkspaceBusinessModel) {
        workspaceCoreDataManager.insertIntoLocalAsyncBlocking(item: item)
    }
    
    private func updateIntoLocal(item: WorkspaceBusinessModel) {
        workspaceCoreDataManager.updateIntoLocalAsyncBlocking(item: item)
    }
    
    private func deleteIntoLocal(item: WorkspaceBusinessModel) {
        workspaceCoreDataManager.deleteIntoLocalAsyncBlocking(item: item)
    }
    
    func insertIntoServer(item: WorkspaceBusinessModel) {
        workspaceService.createNewWorkspace(accessToken: startupUtils.getAccessToken(),
                                            requestBody: WorkspaceRequest(title: item.title, description: item.mainDescription ?? "",
                                               shareEnabled: false))
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
