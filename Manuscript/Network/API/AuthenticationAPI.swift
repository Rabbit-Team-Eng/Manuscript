//
//  AuthenticationAPI.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

public protocol AuthenticationAPI {

    func signUp(body: UserRequest) -> AnyPublisher<AccessTokenResponse, AuthenticationError>

    func signIn(email: String, password: String) -> AnyPublisher<AccessTokenResponse, AuthenticationError>

    func forgotPassword(email: String) -> AnyPublisher<UserResponse, AuthenticationError>

    func resetPassword(body: ResetPasswordRequestModel, email: String, token: String) -> AnyPublisher<UserResponse, AuthenticationError>
}
