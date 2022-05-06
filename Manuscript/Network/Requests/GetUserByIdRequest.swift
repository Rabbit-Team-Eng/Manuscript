//
//  GetUserByIdRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class GetUserByIdRequest {

    private let environment: ManuscriptEnvironment
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    public init(environment: ManuscriptEnvironment, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.environment = environment
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func getRequest(with id: String) -> URLRequest {
        let stringUrl = "\(environment.rawValue)user/\(id)"
        var request = URLRequest(url: URL(string: stringUrl)!)
        request.httpMethod = ServiceConstants.GET
        request.addValue(ServiceConstants.APPLICATION_JSON, forHTTPHeaderField: ServiceConstants.ACCEPT)
        return request
    }
}
