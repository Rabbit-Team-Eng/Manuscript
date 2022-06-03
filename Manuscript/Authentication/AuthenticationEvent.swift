//
//  AuthenticationEvent.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

enum AuthenticationEvent: String {
    case didSignedUpSuccessfully
    case didSignedInSuccessfully
    case wrongFormatForEmail = "Please use correct email."
    case wrongFormatForPassword = "Password should include one upper case character and one symbol."
    case wrongFormarForBothEmailAndPassword = "Please check formatting for Email and Password."
    case unableToSignIn = "Unable to sign in, please check the credentials."
}
