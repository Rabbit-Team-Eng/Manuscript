//
//  UserDefaults.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

extension UserDefaults {

    @Defaults(key: "accessToken", defaultValue: "")
    static var accessToken: String

    @Defaults(key: "isOnboarded", defaultValue: false)
    static var isOnboarded: Bool

    @Defaults(key: "environment", defaultValue: ManuscriptEnvironment.production)
    static var environment: ManuscriptEnvironment
    
    @Defaults(key: "selectedWorkspaceId", defaultValue: Constants.emptyString)
    static var selectedWorkspaceId: String
    
    @Defaults(key: "userId", defaultValue: Constants.emptyString)
    static var userId: String

}
