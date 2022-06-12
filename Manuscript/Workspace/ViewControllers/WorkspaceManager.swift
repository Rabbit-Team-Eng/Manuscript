//
//  WorkspaceManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/11/22.
//

import Foundation

protocol WorkspaceDataProvider {
    var id: Int64 { get set }
    var title: String { get set }

}

class WorkspaceManager: WorkspaceDataProvider {
    
    var id: Int64
    var title: String
    
    init(currentWorkspace: WorkspaceBusinessModel){
        self.id = currentWorkspace.remoteId
        self.title = currentWorkspace.title
    }

}
