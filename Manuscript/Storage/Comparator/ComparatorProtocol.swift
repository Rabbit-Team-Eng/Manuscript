//
//  Comparator.swift
//  task-ios
//
//  Created by Tigran Ghazinyan on 3/25/22.
//

import Foundation

public protocol ComparatorProtocol {
    
    associatedtype Model where Model : BusinessModelProtocol

    static func compare(responseCollection: [Model], cachedCollection: [Model]) -> [ComparatorResult<Model>]
}

extension ComparatorProtocol {

    public static func compare(responseCollection: [Model], cachedCollection: [Model]) -> [ComparatorResult<Model>] {
        
        let sortedResponseCollection = responseCollection.sorted()
        let sortedCachedCollection = cachedCollection.sorted()

        var insertions: [Model] = []
        var removals: [Model] = []
        var returningComparatorResultCollection: [ComparatorResult<Model>] = []

        let diff = sortedResponseCollection.difference(from: sortedCachedCollection)

        for change in diff {
            switch change {
            case let .remove(_, element, _):
                removals.append(element)
            case let .insert(_, element, _):
                insertions.append(element)
            }
        }

        insertions.forEach { toBeInsertedItem in
            returningComparatorResultCollection.append(ComparatorResult(operation: .insertion, target: .local, businessObject: toBeInsertedItem))
        }

        removals.forEach { toBeRemovedItem in

            let existingItemBothInInsertionsAndRemovals = insertions.first { $0.remoteId == toBeRemovedItem.remoteId }

            let needToBeInsertedInToServer = existingItemBothInInsertionsAndRemovals == nil && toBeRemovedItem.isInitiallySynced == false
            let needToBeRemovedFromLocalDb = existingItemBothInInsertionsAndRemovals == nil && toBeRemovedItem.isInitiallySynced && toBeRemovedItem.isPendingDeletionOnTheServer == false
            let needToBeRemovedFromServer = existingItemBothInInsertionsAndRemovals == nil && toBeRemovedItem.isInitiallySynced && toBeRemovedItem.isPendingDeletionOnTheServer != false
            
            if needToBeInsertedInToServer {
                returningComparatorResultCollection.append(ComparatorResult(operation: .insertion, target: .server, businessObject: toBeRemovedItem))
            }
            
            if needToBeRemovedFromLocalDb {
                returningComparatorResultCollection.append(ComparatorResult(operation: .removal, target: .local, businessObject: toBeRemovedItem))
            }
            
            if needToBeRemovedFromServer {
                returningComparatorResultCollection.append(ComparatorResult(operation: .removal, target: .server, businessObject: toBeRemovedItem))
            }
            
            if existingItemBothInInsertionsAndRemovals != nil {
                for (index, alreadyInInsertionsItem) in returningComparatorResultCollection.enumerated() {

                    if alreadyInInsertionsItem.businessObject.remoteId == toBeRemovedItem.remoteId {

                        // Local Is More Up To Date
                        if alreadyInInsertionsItem.businessObject.lastModifiedDate < toBeRemovedItem.lastModifiedDate {
                            let newUpdate = ComparatorResult(operation: .update, target: .server, businessObject: toBeRemovedItem)
                            returningComparatorResultCollection.remove(at: index)
                            returningComparatorResultCollection.append(newUpdate)
                        }

                        // Remote Is More Up To Date
                        if alreadyInInsertionsItem.businessObject.lastModifiedDate > toBeRemovedItem.lastModifiedDate {
                            var mergedLocalCoreDataIdWithMoreFreshServerVersion = alreadyInInsertionsItem.businessObject
                            mergedLocalCoreDataIdWithMoreFreshServerVersion.coreDataId = toBeRemovedItem.coreDataId
                            let newUpdate = ComparatorResult(operation: .update, target: .local, businessObject: mergedLocalCoreDataIdWithMoreFreshServerVersion)
                            returningComparatorResultCollection.remove(at: index)
                            returningComparatorResultCollection.append(newUpdate)
                        }
                    }

                }
            }
        }
        return returningComparatorResultCollection
    }
}
