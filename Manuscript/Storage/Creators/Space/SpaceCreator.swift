//
//  SpaceCreator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 7/2/22.
//

import Foundation
import CoreData
import Combine


class SpaceCreator {
    
    private let spaceService: SpaceService
    private let database: CoreDataStack
    private let dataProvider: DataProvider

    private var tokens: Set<AnyCancellable> = []
    
    init(spaceService: SpaceService, database: CoreDataStack, dataProvider: DataProvider) {
        self.spaceService = spaceService
        self.database = database
        self.dataProvider = dataProvider
    }
    
    func createNewSpace(space: SpaceCreateCoreDataRequest, databaseCompletion: @escaping () -> Void, serverCompletion: @escaping () -> Void) {
        let context = self.database.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            let workspaceEntity = WorkspaceEntity(context: context)
            workspaceEntity.remoteId = -1
            workspaceEntity.title = space.title
            workspaceEntity.mainDescription = space.mainDescription
            workspaceEntity.sharingEnabled = space.sharingEnabled
            workspaceEntity.lastModifiedDate = space.lastModifiedDate
            workspaceEntity.isInitiallySynced = space.isInitiallySynced
            workspaceEntity.isPendingDeletionOnTheServer = space.isPendingDeletionOnTheServer
            
            do {
                try context.save()
                databaseCompletion()
                UserDefaults.selectedWorkspaceId = "\(workspaceEntity.remoteId)"
                self.insertIntoServer(item: space, coreDataId: workspaceEntity.objectID) {
                    serverCompletion()
                }
            } catch {
                fatalError()
            }
        }
    }
    
    private func insertIntoServer(item: SpaceCreateCoreDataRequest, coreDataId: NSManagedObjectID, serverCompletion: @escaping () -> Void) {
        spaceService.createNewWorkspace(requestBody: WorkspaceRequest(title: item.title, description: item.mainDescription, shareEnabled: item.sharingEnabled))
            .sink { completion in } receiveValue: { spaceResponse in
                
                let context = self.database.databaseContainer.newBackgroundContext()
                context.automaticallyMergesChangesFromParent = true
                
                context.performAndWait {
                    if let spaceToBeUpdated = try? context.existingObject(with: coreDataId) as? WorkspaceEntity {
                        spaceToBeUpdated.remoteId = Int64(spaceResponse.id)
                        UserDefaults.selectedWorkspaceId = "\(spaceResponse.id)"
                        spaceToBeUpdated.lastModifiedDate = spaceResponse.lastModifiedDate
                        spaceToBeUpdated.isInitiallySynced = true
                        
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
