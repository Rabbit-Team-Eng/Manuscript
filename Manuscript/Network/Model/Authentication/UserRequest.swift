//
//  UserRequest.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct UserRequest: Codable {

    public let email: String
    public var password: String
    public var passwordConfirm: String

    public init(email: String, password: String, passwordConfirm: String) {
        self.email = email
        self.password = password
        self.passwordConfirm = passwordConfirm
    }
}


