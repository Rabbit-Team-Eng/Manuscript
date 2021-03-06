//
//  AuthenticationViewModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

class AuthenticationViewModel {

    private let startupUtils: StartupUtils
    private let authenticationManager: AuthenticationManager

    public let authenticationEventPublisher: PassthroughSubject<AuthenticationEvent, Never> = PassthroughSubject()

    private var tokens: Set<AnyCancellable> = []

    init(startupUtils: StartupUtils, authenticationManager: AuthenticationManager) {
        self.startupUtils = startupUtils
        self.authenticationManager = authenticationManager
    }

    func createNewUser(name: String, email: String, password: String) {

        authenticationManager.signUp(body: UserRequest(email: email, password: password, passwordConfirm: password))
                .sink(receiveCompletion: { completion in  }, receiveValue: { [weak self] accessTokenResponse in
                    guard let self = self else { return }
                    self.startupUtils.saveAccessToken(token: accessTokenResponse.access_token)
                    self.authenticationEventPublisher.send(.didSignedUpSuccessfully)
                })
                .store(in: &tokens)
        

    }

    func signIn(email: String, password: String) {
        
        if email == Constants.emptyString && password != Constants.emptyString {
            authenticationEventPublisher.send(.wrongFormatForEmail)
        } else if password == Constants.emptyString && email != Constants.emptyString {
            authenticationEventPublisher.send(.wrongFormatForPassword)
        } else if email == Constants.emptyString && password == Constants.emptyString {
            authenticationEventPublisher.send(.wrongFormarForBothEmailAndPassword)
        } else if email != Constants.emptyString && password != Constants.emptyString {
            authenticationManager.signIn(email: email, password: password)
                    .sink(receiveCompletion: { completion in  }, receiveValue: { [weak self] accessTokenResponse in
                        guard let self = self else { return }
                        self.startupUtils.saveAccessToken(token: accessTokenResponse.access_token)
                        UserDefaults.userId = accessTokenResponse.userId
                        self.authenticationEventPublisher.send(.didSignedInSuccessfully)
                    })
                    .store(in: &tokens)
        }
        
    }
    
    deinit {

    }
}
