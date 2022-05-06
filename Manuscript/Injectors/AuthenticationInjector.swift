//
//  AuthenticationInjector.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class AuthenticationInjector {

    // Local Scope
    private var authenticationManager: AuthenticationManager? = nil
    private var authenticationViewModel: AuthenticationViewModel? = nil

    // Injected from Application Scope
    private let startupUtils: StartupUtils
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    init(applicationInjector: ApplicationInjector) {
        self.startupUtils = applicationInjector.provideStartupUtils()
        self.jsonDecoder = applicationInjector.provideJsonDecoder()
        self.jsonEncoder = applicationInjector.provideJsonEncoder()
        print("AVERAKEDABRA: ALLOC -> AuthenticationComponent")
    }

    func provideAuthenticationViewModel() -> AuthenticationViewModel {
        if authenticationViewModel != nil {
            return authenticationViewModel!
        } else  {
            authenticationViewModel = AuthenticationViewModel(startupUtils: startupUtils, authenticationManager: provideAuthenticationManager())
            return authenticationViewModel!
        }
    }

    func provideAuthenticationManager() -> AuthenticationManager {
        if authenticationManager != nil {
            return authenticationManager!
        } else {
            authenticationManager = AuthenticationManager(environment: startupUtils.provideEnvironment(), jsonDecoder: jsonDecoder, jsonEncoder: jsonEncoder)
            return authenticationManager!
        }
    }

    deinit {
        print("AVERAKEDABRA: RELEASE -> AuthenticationComponent")
    }
}
