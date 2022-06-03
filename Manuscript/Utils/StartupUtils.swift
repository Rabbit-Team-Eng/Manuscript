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

    func getAccessToken() -> String {
        if let data = KeychainHelper.standard.read(service: "access-token", account: "custom") {
            let accessToken = String(data: data, encoding: .utf8)!
            return accessToken
        }
        return ""
    }

    func saveAccessToken(token: String) {
        let accessToken = token
        let data = Data(accessToken.utf8)
        KeychainHelper.standard.save(data, service: "access-token", account: "custom")
    }
    
    func deleteAcessToken() {
        KeychainHelper.standard.delete(service: "access-token", account: "custom")
    }

    func provideEnvironment() -> ManuscriptEnvironment {
        return UserDefaults.environment
    }

    func setEnvironment(environment: ManuscriptEnvironment) {
        UserDefaults.environment = environment
    }
}
