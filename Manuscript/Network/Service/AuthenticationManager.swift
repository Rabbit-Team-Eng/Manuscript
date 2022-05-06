//
//  AuthenticationManager.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation
import Combine

public class AuthenticationManager: AuthenticationAPI {

    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let environment: ManuscriptEnvironment

    init(environment: ManuscriptEnvironment, jsonDecoder: JSONDecoder, jsonEncoder: JSONEncoder) {
        self.jsonDecoder = jsonDecoder
        self.jsonEncoder = jsonEncoder
        self.environment = environment
    }

    public func signUp(body: UserRequest) -> AnyPublisher<AccessTokenResponse, AuthenticationError> {

        return createNewUser(body: body)
                .compactMap { $0 }
                .mapError({ error in
                    return AuthenticationError.unableToSignUp
                })
                .flatMap { userResponse in
                    return self.signIn(email: body.email, password: body.password)
                }
                .mapError({ error in
                    return AuthenticationError.unableToSignUp
                })
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }

    public func signIn(email: String, password: String) -> AnyPublisher<AccessTokenResponse, AuthenticationError> {

        let request = SignInUserRequest(environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        return URLSession.shared
                .dataTaskPublisher(for: request.getRequest(email: email, password: password))
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        fatalError("Status code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                    }
                    return element.data
                }
                .decode(type: AccessTokenResponse.self, decoder: jsonDecoder)
                .mapError({ error in
                    return AuthenticationError.unableToSignIn
                })
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }

    public func forgotPassword(email: String) -> AnyPublisher<UserResponse, AuthenticationError> {
        let request = ForgotPasswordRequest(environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)

        return URLSession.shared
                .dataTaskPublisher(for: request.getRequest(with: email))
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        fatalError("Bad Response")
                    }
                    return element.data
                }
                .decode(type: UserResponse.self, decoder: jsonDecoder)
                .mapError({ error in
                    return AuthenticationError.unableToForgotPassword
                })
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }

    public func resetPassword(body: ResetPasswordRequestModel, email: String, token: String) -> AnyPublisher<UserResponse, AuthenticationError> {
        let request = ResetPasswordRequest(environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
        return URLSession.shared
                .dataTaskPublisher(for: request.getRequest(with: body, email: email, token: token))
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        fatalError("Bad Response")
                    }
                    return element.data
                }
                .decode(type: UserResponse.self, decoder: jsonDecoder)
                .mapError({ error in
                    return AuthenticationError.unableToResetPassword
                })
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }

    private func createNewUser(body: UserRequest) -> AnyPublisher<UserResponse, AuthenticationError> {
        let request = CreateNewUserRequest(environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)

        return URLSession.shared
                .dataTaskPublisher(for: request.getRequest(with: body))
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                        fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")
                    }
                    return element.data
                }
                .decode(type: UserResponse.self, decoder: jsonDecoder)
                .mapError({ error in
                    return AuthenticationError.unableToCreateUser
                })
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }

    private func getUserById(id: String) -> AnyPublisher<UserResponse, AuthenticationError> {
        let request = GetUserByIdRequest(environment: environment, jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)

        return URLSession.shared
                .dataTaskPublisher(for: request.getRequest(with: id))
                .tryMap() { element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        fatalError("Bad Response, code is: \(String(describing: (element.response as? HTTPURLResponse)?.statusCode))")                }
                    return element.data
                }
                .decode(type: UserResponse.self, decoder: jsonDecoder)
                .mapError({ error in
                    return AuthenticationError.unableToGetUser
                })
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }
}
