//
// Created by Tigran Ghazinyan on 3/26/22.
//

import Foundation

public struct ComparatorResult<T: BusinessModelProtocol> {

    public let operation: ComparatorAction
    public let businessObject: T
    public let target: ComparatorResultTarget

    public init(operation: ComparatorAction, target: ComparatorResultTarget, businessObject: T) {
        self.operation = operation
        self.target = target
        self.businessObject = businessObject
    }
}
