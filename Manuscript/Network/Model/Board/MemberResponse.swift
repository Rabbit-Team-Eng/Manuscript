//
//  MemberResponse.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public struct MemberResponse: Codable {
    
    public var id: String
    public var firstName: String? = nil
    public var lastName: String? = nil
    public var email: String
    public var avatarUrl: String? = nil
    public var isWorkspaceOwner: Bool
    public var lastModifiedDate: String

    public init(id: String, firstName: String, lastName: String, email: String, avatarUrl: String, isWorkspaceOwner: Bool, lastModifiedDate: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatarUrl = avatarUrl
        self.isWorkspaceOwner = isWorkspaceOwner
        self.lastModifiedDate = lastModifiedDate
    }
}
