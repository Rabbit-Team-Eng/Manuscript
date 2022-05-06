//
//  StartupUtils.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class StartupUtils {

    func isOnboarded() -> Bool {
        return UserDefaults.isOnboarded
    }

    func didFinishOnboarding() {
        UserDefaults.isOnboarded = true
    }

    func getAccessToken() -> String? {
        return UserDefaults.accessToken
    }

    func saveAccessToken(token: String) {
        UserDefaults.accessToken = token
    }

    func provideEnvironment() -> ManuscriptEnvironment {
        return UserDefaults.environment
    }

    func setEnvironment(environment: ManuscriptEnvironment) {
        UserDefaults.environment = environment
    }
}
