//
//  AuthenticationError.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

public enum AuthenticationError: Error {
    case unableToSignUp
    case unableToSignIn
    case unableToResetPassword
    case unableToForgotPassword
    case unableToCreateUser
    case unableToGetUser
}
