//
//  CreateNewUserRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

struct CreateNewUserRequest {

    private let environment: ManuscriptEnvironment
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    public init(environment: ManuscriptEnvironment, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.environment = environment
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func getRequest(with body: UserRequest) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(environment.rawValue)user")!)
        request.httpMethod = ServiceConstants.POST
        request.httpBody = try? jsonEncoder.encode(body)
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.CONTENT_TYPE)
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.ACCEPT)
        return request
    }
}
