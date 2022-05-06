//
//  ResetPasswordRequestModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct ResetPasswordRequestModel: Codable {

    public let password: String
    public let confirmPassword: String

    public init(password: String, confirmPassword: String) {
        self.password = password
        self.confirmPassword = confirmPassword
    }
}
