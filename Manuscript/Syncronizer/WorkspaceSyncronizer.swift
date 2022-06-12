//
//  WorkspaceSyncronizer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/10/22.
//

import CoreData
import Combine

enum WorkspaceSyncronizerState {
    case initial
    case done
}

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
    
    func syncronize(items: [ComparatorResult<Model>], completion: @escaping () -> Void) {
        let group = DispatchGroup()
            
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
            group.enter()
            insertIntoServer(item: workspaceBusinessModelToBeInserted) {
                group.leave()
            }
        }
        
        items.filter { $0.target == .server && $0.operation == .update }.map { $0.businessObject }.forEach { workspaceBusinessModelToBeInserted in
            group.enter()
            updateIntoServer(item: workspaceBusinessModelToBeInserted) {
                group.leave()
            }
        }
        
        items.filter { $0.target == .server && $0.operation == .removal }.map { $0.businessObject }.forEach { workspaceBusinessModelToBeDeleted in
            group.enter()
            deleteIntoServer(item: workspaceBusinessModelToBeDeleted) {
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
            completion()
        }
    }


    
    private func insertIntoLocal(item: WorkspaceBusinessModel) {
        workspaceCoreDataManager.insertIntoLocalOnBackgroundThread(item: item)
    }
    
    private func updateIntoLocal(item: WorkspaceBusinessModel) {
        workspaceCoreDataManager.updateIntoLocalInBackgrooundThread(item: item)
    }
    
    private func deleteIntoLocal(item: WorkspaceBusinessModel) {
        workspaceCoreDataManager.deleteInLocalOnBackgroundThread(item: item)
    }
    
    private func insertIntoServer(item: WorkspaceBusinessModel, completion: @escaping () -> Void) {
        workspaceService.createNewWorkspace(requestBody: WorkspaceRequest(title: item.title, description: item.mainDescription ?? "",
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
                        completion()
                    } catch {
                        fatalError()
                    }
                }
            }  
        }
        .store(in: &tokens)
    }
    
    private func updateIntoServer(item: WorkspaceBusinessModel, completion: @escaping () -> Void) {
        workspaceService.updateWorkspaceById(workspaceId: "\(item.remoteId)", body: WorkspaceRequest(title: item.title,
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
                        completion()
                    } catch {
                        fatalError()
                    }
                }
            }
            
        }
        .store(in: &tokens)
    }
    
    private func deleteIntoServer(item: WorkspaceBusinessModel, completion: @escaping () -> Void) {
        workspaceService.deleteWorkspaceById(workspaceId: "\(item.remoteId)")
        .sink { completion in } receiveValue: { response in
            print(response)
            completion()
        }
        .store(in: &tokens)
    }
    
}
