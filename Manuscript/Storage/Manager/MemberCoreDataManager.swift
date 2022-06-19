//
//  MemberCoreDataManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/18/22.
//

import CoreData

class MemberCoreDataManager {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    func insertNewMembers(latestMembers: [MemberBusinessModel]) {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: "MemberEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs

        let context = self.coreDataStack.databaseContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        
        context.performAndWait {
            do {
                let batchDelete = try context.execute(deleteRequest) as? NSBatchDeleteResult
                guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }
                let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [context])

                try latestMembers.forEach { member in
                    let workspacesFetchRequest: NSFetchRequest<WorkspaceEntity> = NSFetchRequest(entityName: "WorkspaceEntity")
                    workspacesFetchRequest.predicate = NSPredicate(format: "remoteId == %@", "\(member.ownerWorkspaceId)")
                    let workspaces: [WorkspaceEntity] = try context.fetch(workspacesFetchRequest)
                    
                    if let worskpaceEntity = workspaces.first {
                        let memberCoreDataEntity = MemberEntity(context: context)
                        memberCoreDataEntity.remoteId = member.remoteId
                        memberCoreDataEntity.avatarUrl = member.avatarUrl
                        memberCoreDataEntity.email = member.email
                        memberCoreDataEntity.firstName = member.firstName
                        memberCoreDataEntity.isInitiallySynced = member.isInitiallySynced
                        memberCoreDataEntity.isPendingDeletionOnTheServer = member.isPendingDeletionOnTheServer
                        memberCoreDataEntity.isWorkspaceOwner = member.isWorkspaceOwner
                        memberCoreDataEntity.lastModifiedDate = DateTimeUtils.convertDateToServerString(date: member.lastModifiedDate)
                        memberCoreDataEntity.lastName = member.lastName
                        memberCoreDataEntity.ownerWorkspaceId = member.ownerWorkspaceId
                        worskpaceEntity.addToMembers(memberCoreDataEntity)
                        try context.save()
                    }
                }
                

            } catch {
                fatalError()
            }
        }
    }
}
