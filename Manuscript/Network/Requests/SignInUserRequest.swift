//
//  SignInUserRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class SignInUserRequest {

    private let environment: ManuscriptEnvironment
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    public init(environment: ManuscriptEnvironment, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.environment = environment
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func getRequest(email: String, password: String) -> URLRequest {
        let loginString = String(format: "%@:%@", email, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()

        let urlString = "\(environment.rawValue)OAuth/access_token"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = ServiceConstants.POST
        request.setValue("\(ServiceConstants.BASIC) \(base64LoginString)", forHTTPHeaderField: ServiceConstants.AUTHORIZATION)
        return request
    }
}
