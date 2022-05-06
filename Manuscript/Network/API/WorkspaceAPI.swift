//
//  WorkspaceAPI.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

public protocol WorkspaceAPI {
    
    func createNewWorkspace(accessToken: String, requestBody: WorkspaceRequest) -> AnyPublisher<WorkspaceResponse, Error>
    
    func getWorkspaceById(accessToken: String, workspaceId: String) -> AnyPublisher<WorkspaceResponse, Error>
    
    func getAllWorkspaces(accessToken: String, pageNumber: Int, pageSize: Int) -> AnyPublisher<AllWorkspaceResponse, Error>
    
    func updateWorkspaceById(accessToken: String, workspaceId: String, body: WorkspaceRequest) -> AnyPublisher<WorkspaceResponse, Error>

    func deleteWorkspaceById(accessToken: String, workspaceId: String) -> AnyPublisher<WorkspaceResponse, Error>
    
    func getWorkspaceShareUrlById(accessToken: String, workspaceId: String) -> AnyPublisher<String, Error>
    
    func addCurrentUserToWorkspaceByWorkspaceId(accessToken: String, workspaceId: String) -> AnyPublisher<MemberResponse, Error>

}
