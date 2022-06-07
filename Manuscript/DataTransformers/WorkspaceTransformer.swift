//
//  WorkspaceTransformer.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/6/22.
//

import Foundation

struct WorkspaceTransformer {
    
    static func transformWorkspacesToSelectorCellModel(workspaces: [WorkspaceBusinessModel]) -> [WorkspaceSelectorCellModel] {
        let firstSelectedWorkspace = workspaces.filter { "\($0.remoteId)" == UserDefaults.selectedWorkspaceId }
        let allTheOthers = workspaces.filter { "\($0.remoteId)" != UserDefaults.selectedWorkspaceId }
        let correctOrderedWorksapces = firstSelectedWorkspace + allTheOthers.sorted()
        return correctOrderedWorksapces.map { WorkspaceSelectorCellModel(id: "\($0.remoteId)", title: $0.title, isEditable: false) }
    }
}
