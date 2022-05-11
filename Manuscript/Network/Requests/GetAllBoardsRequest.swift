//
//  GetAllBoardsRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

struct GetAllBoardsRequest {
    
    private let environment: ManuscriptEnvironment
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private let accessToken: String

    public init(accessToken: String, environment: ManuscriptEnvironment, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.accessToken = accessToken
        self.environment = environment
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    func getPredicateRequest(workspaceId: String, with pageNumber: Int, pageSize: Int) -> URLRequest {
        let urlString = "\(environment.rawValue)\(Endpoint.board)?WorkspaceId=\(workspaceId)&PageSize=\(pageSize)&PageNumber=\(pageNumber)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = ServiceConstants.GET
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.ACCEPT)
        request.addValue("\(ServiceConstants.BEARER) \(accessToken)", forHTTPHeaderField: ServiceConstants.AUTHORIZATION)
        return request
    }

    func getRequest(workspaceId: String) -> URLRequest {
        let urlString = "\(environment.rawValue)\(Endpoint.board)?WorkspaceId=\(workspaceId)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = ServiceConstants.GET
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.ACCEPT)
        request.addValue("\(ServiceConstants.BEARER) \(accessToken)", forHTTPHeaderField: ServiceConstants.AUTHORIZATION)
        return request
    }
    
    func getAllBoards() -> URLRequest {
        let urlString = "\(environment.rawValue)\(Endpoint.board)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = ServiceConstants.GET
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.ACCEPT)
        request.addValue("\(ServiceConstants.BEARER) \(accessToken)", forHTTPHeaderField: ServiceConstants.AUTHORIZATION)
        return request
    }
}
