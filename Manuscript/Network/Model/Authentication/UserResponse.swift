//
//  UserResponse.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct UserResponse: Codable {

    public let id: String
    public var firstName: String?
    public var lastName: String?
    public let email: String

    public init(id: String, firstName: String? = nil, lastName: String? = nil, email: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
