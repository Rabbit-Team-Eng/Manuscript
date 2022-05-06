//
//  ResetPasswordRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class ResetPasswordRequest {

    private let environment: ManuscriptEnvironment
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    public init(environment: ManuscriptEnvironment, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.environment = environment
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func getRequest(with body: ResetPasswordRequestModel, email: String, token: String) -> URLRequest {
        var url = URLComponents(string: "\(environment.rawValue)reset-password")!

        url.queryItems = [
            URLQueryItem(name: "email", value: "\(email)"),
            URLQueryItem(name: "token", value: "\(token)")
        ]

        var request = URLRequest(url: url.url!)
        request.httpMethod = ServiceConstants.PUT
        request.httpBody = try? jsonEncoder.encode(body)
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.CONTENT_TYPE)
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.ACCEPT)
        return request
    }

}
