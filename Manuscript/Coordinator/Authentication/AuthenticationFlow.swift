//
//  AuthenticationFlow.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

enum AuthenticationFlow: Flowable {

    case signIn
    case register
    case forgotPassword

    func getNavigationEntryDeepLink() -> String {
        switch self {
        case .forgotPassword:
            return "thesis://authentication/forgotPassword"
        case .register:
            return "thesis://authentication/register"
        case .signIn:
            return "thesis://authentication/signIn"
        }
    }
}
