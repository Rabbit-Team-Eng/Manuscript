//
//  WorksapceDetailState.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/10/22.
//

import Foundation

enum WorksapceDetailState {
    case create
    case edit(workspace: WorkspaceBusinessModel)
    case view(workspace: WorkspaceBusinessModel)
}
