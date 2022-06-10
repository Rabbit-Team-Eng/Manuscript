//
//  WorkspaceDetailActionsProtocol.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import Foundation

protocol WorkspaceDetailActionsProtocol: NSObject {
    func actionDidHappen(action: WorkspaceDetailAction)
}
