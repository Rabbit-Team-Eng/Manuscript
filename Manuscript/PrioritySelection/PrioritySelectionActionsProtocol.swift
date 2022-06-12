//
//  PrioritySelectionActionsProtocol.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import Foundation

protocol PrioritySelectionActionsProtocol: NSObject {
    func actionDidHappen(action: PrioritySelectionAction)
}
