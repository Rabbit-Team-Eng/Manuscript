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

    // TODO: Need to revisit this and make sure that the value depends on the build type
    @Defaults(key: "environment", defaultValue: ManuscriptEnvironment.production)
    static var environment: ManuscriptEnvironment


}
