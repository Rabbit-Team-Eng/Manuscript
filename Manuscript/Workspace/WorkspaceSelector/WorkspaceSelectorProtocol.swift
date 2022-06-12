//
//  WorkspaceSelectorProtocol.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import UIKit

protocol WorkspaceSelectorProtocol: NSObject {
    func workspaceDetailFlowDidSelected(model: WorkspaceSelectorCellModel)
}
