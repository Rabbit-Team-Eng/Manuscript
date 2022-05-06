//
//  WorkspaceService.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

public class WorkspaceService: WorkspaceAPI {
    
    private let environment: ManuscriptEnvironment
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private let accessToken: String

    init(accessToken: String, environment: ManuscriptEnvironment, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.accessToken = accessToken
        self.environment = environment
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    public func createNewWorkspace(accessToken: String, requestBody: WorkspaceRequest) -> AnyPublisher<WorkspaceResponse, Error> {

        
        let request = CreateNewWorkspaceRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(with: requestBody))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: WorkspaceResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return WorkspaceError.unableToCreateWorkspace(error: error)
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func getWorkspaceById(accessToken: String, workspaceId: String) -> AnyPublisher<WorkspaceResponse, Error> {
        
        let request = GetWorkspaceByIdRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(with: workspaceId))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: WorkspaceResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return WorkspaceError.unableToGeWorkspaceById(error: error)
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func getAllWorkspaces(accessToken: String, pageNumber: Int, pageSize: Int) -> AnyPublisher<AllWorkspaceResponse, Error> {

        let request = GetAllWorkspacesRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(with: pageNumber, pageSize: pageSize))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: AllWorkspaceResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return WorkspaceError.unableToGetAllWorkspaces(error: error)
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
//    func getAllWorkspacesAsBusinessObjects(accessToken: String,
//                                                  pageNumber: Int = 1,
//                                                  pageSize: Int = 100) -> AnyPublisher<[WorkspaceBusinessModel], Error> {
//
//        let request = GetAllWorkspacesRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
//        
//        return URLSession.shared
//            .dataTaskPublisher(for: request.getRequest(with: pageNumber, pageSize: pageSize))
//            .tryMap() { element -> Data in
//                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
//                }
//                return element.data
//            }
//            .decode(type: AllWorkspaceResponse.self, decoder: jsonDecoder)
//            .map { allWorkspaceResponse in
//                var workspaces: [WorkspaceBusinessModel] = []
//                allWorkspaceResponse.items.forEach { workspaceResponse in
//                    var members: [MemberBusinessModel] = []
//                    var boards: [BoardBusinessModel] = []
//
//                    workspaceResponse.members?.forEach { memberResponse in
//                        members.append(MemberBusinessModel(remoteId: -999, // TODO: "Int32(memberResponse.id)",
//                                                           firstName: memberResponse.firstName ?? "null",
//                                                           lastName: memberResponse.lastName ?? "null",
//                                                           avatarUrl: memberResponse.avatarUrl ?? "null",
//                                                           email: memberResponse.email,
//                                                           isWorkspaceOwner: memberResponse.isWorkspaceOwner,
//                                                           ownerWorkspaceId: Int32(workspaceResponse.id),
//                                                           lastModifiedDate: memberResponse.lastModifiedDate,
//                                                           isInitiallySynced: true,
//                                                           isPendingDeletionOnTheServer: false))
//                    }
//                    
//                    workspaceResponse.boards?.forEach { boardResponse in
//                        var tasks: [TaskBusinessModel] = []
//
//                        boardResponse.tasks?.forEach { taskResponse in
//                            tasks.append(TaskBusinessModel(remoteId: Int32(taskResponse.id),
//                                                           title: taskResponse.title,
//                                                           detail: taskResponse.detail,
//                                                           dueDate: taskResponse.doeDate,
//                                                           ownerBoardId: Int32(taskResponse.boardId),
//                                                           status: taskResponse.status ?? "",
//                                                           workspaceId: Int32(taskResponse.workspaceId),
//                                                           lastModifiedDate: taskResponse.lastModifiedDate,
//                                                           isInitiallySynced: true,
//                                                           isPendingDeletionOnTheServer: false))
//                        }
//                        
//                        boards.append(BoardBusinessModel(remoteId: Int32(boardResponse.id),
//                                                         title: boardResponse.title,
//                                                         assetUrl: boardResponse.assetUrl ?? "null",
//                                                         ownerWorkspaceId: Int32(boardResponse.workspaceId),
//                                                         lastModifiedDate: boardResponse.lastModifiedDate,
//                                                         tasks: tasks,
//                                                         isInitiallySynced: true,
//                                                         isPendingDeletionOnTheServer: false))
//                        
//
//                    }
//                    
//
//                    let workspaceBO = WorkspaceBusinessModel(remoteId: Int32(workspaceResponse.id),
//                                                             title: workspaceResponse.title,
//                                                             mainDescription: workspaceResponse.description,
//                                                             sharingEnabled: workspaceResponse.shareEnabled,
//                                                             boards: boards,
//                                                             members: members,
//                                                             lastModifiedDate: workspaceResponse.lastModifiedDate,
//                                                             isInitiallySynced: true,
//                                                             isPendingDeletionOnTheServer: false)
//                    workspaces.append(workspaceBO)
//                    
//                }
//                return workspaces
//            }
//            .mapError({ error in
//                return WorkspaceError.unableToGetAllWorkspaces(error: error)
//            })
//            .receive(on: RunLoop.main)
//            .eraseToAnyPublisher()
//    }
    
    public func updateWorkspaceById(accessToken: String, workspaceId: String, body: WorkspaceRequest) -> AnyPublisher<WorkspaceResponse, Error> {

        let request = UpdateWorkspaceByIdRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(with: workspaceId, body: body))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: WorkspaceResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return WorkspaceError.unableToUpdateWorkspaceById(error: error)
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func deleteWorkspaceById(accessToken: String, workspaceId: String) -> AnyPublisher<WorkspaceResponse, Error> {
        
        let request = DeleteWorkspaceByIdRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(with: workspaceId))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: WorkspaceResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return WorkspaceError.unableToDeleteWorkspaceById(error: error)
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func getWorkspaceShareUrlById(accessToken: String, workspaceId: String) -> AnyPublisher<String, Error> {

        let request = GetWorkspaceSharingUrlRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(with: workspaceId))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: String.self, decoder: jsonDecoder)
            .mapError({ error in
                return WorkspaceError.unableToGeWorkspaceSharingUrlById(error: error)
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    public func addCurrentUserToWorkspaceByWorkspaceId(accessToken: String, workspaceId: String) -> AnyPublisher<MemberResponse, Error> {

        let request = GetWorkspaceSharingUrlRequest(accessToken: accessToken, environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        
        return URLSession.shared
            .dataTaskPublisher(for: request.getRequest(with: workspaceId))
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                }
                return element.data
            }
            .decode(type: MemberResponse.self, decoder: jsonDecoder)
            .mapError({ error in
                return WorkspaceError.unableToGeWorkspaceSharingUrlById(error: error)
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
