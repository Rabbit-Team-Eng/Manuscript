//
//  WorkspaceError.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
public enum WorkspaceError: Error {
    case unableToCreateWorkspace(error: Error)
    case unableToGeWorkspaceById(error: Error)
    case unableToGetAllWorkspaces(error: Error)
    case unableToUpdateWorkspaceById(error: Error)
    case unableToDeleteWorkspaceById(error: Error)
    case unableToGeWorkspaceSharingUrlById(error: Error)
    case badResponse(response: Int)
    case badAccessToken
}
