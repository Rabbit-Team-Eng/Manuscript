//
//  ForgotPasswordRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class ForgotPasswordRequest {

    private let environment: ManuscriptEnvironment
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    public init(environment: ManuscriptEnvironment, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.environment = environment
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    func getRequest(with email: String) -> URLRequest {
        var url = URLComponents(string: "\(environment.rawValue)forgot-password")!

        url.queryItems = [
            URLQueryItem(name: "email", value: "\(email)")
        ]

        var request = URLRequest(url: url.url!)
        request.httpMethod = ServiceConstants.GET
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.ACCEPT)
        return request
    }

}
