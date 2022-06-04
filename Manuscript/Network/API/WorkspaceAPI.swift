//
//  WorkspaceAPI.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

public protocol WorkspaceAPI {
    
    func createNewWorkspace(requestBody: WorkspaceRequest) -> AnyPublisher<WorkspaceResponse, Error>
    
    func getWorkspaceById(workspaceId: String) -> AnyPublisher<WorkspaceResponse, Error>
    
    func getAllWorkspaces(pageNumber: Int, pageSize: Int) -> AnyPublisher<AllWorkspaceResponse, Error>
    
    func updateWorkspaceById(workspaceId: String, body: WorkspaceRequest) -> AnyPublisher<WorkspaceResponse, Error>

    func deleteWorkspaceById(workspaceId: String) -> AnyPublisher<WorkspaceResponse, Error>
    
    func getWorkspaceShareUrlById(workspaceId: String) -> AnyPublisher<String, Error>
    
    func addCurrentUserToWorkspaceByWorkspaceId(workspaceId: String) -> AnyPublisher<MemberResponse, Error>

}
