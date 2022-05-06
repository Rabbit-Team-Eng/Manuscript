//
//  AccessTokenResponse.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct AccessTokenResponse: Codable {

    public let userId: String
    public let access_token: String
    public var user_name: String
    public var token_type: String
    public var expires_in: Int

    public init(userId: String, access_token: String, user_name: String, token_type: String, expires_in: Int) {
        self.userId = userId
        self.access_token = access_token
        self.user_name = user_name
        self.token_type = token_type
        self.expires_in = expires_in
    }
}
