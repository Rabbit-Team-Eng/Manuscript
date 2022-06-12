//
// Created by Tigran Ghazinyan on 3/26/22.
//

import Foundation
import CoreData

public protocol BusinessModelProtocol: Comparable {
    var lastModifiedDate: Date { get }
    var isInitiallySynced: Bool { get }
    var isPendingDeletionOnTheServer: Bool { get }
    var remoteId: Int64 { get }
    var coreDataId: NSManagedObjectID? { get set }

}
