//
//  CreateNewBoardRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

struct CreateNewBoardRequest {
    
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
    
    func getRequest(with requestBody: BoardRequest) -> URLRequest {
        let urlString = "\(environment.rawValue)\(Endpoint.board)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = ServiceConstants.POST
        request.httpBody = try? jsonEncoder.encode(requestBody)
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.CONTENT_TYPE)
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.ACCEPT)
        request.addValue("\(ServiceConstants.BEARER) \(accessToken)", forHTTPHeaderField: ServiceConstants.AUTHORIZATION)
        return request
    }
}
