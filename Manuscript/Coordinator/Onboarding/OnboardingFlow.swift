//
//  OnboardingFlow.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

enum OnboardingFlow: Flowable {

    case welcome
    case permissions

    func getNavigationEntryDeepLink() -> String {
        switch self {
        case .welcome:
            return "thesis://onboarding/welcome"
        case .permissions:
            return "thesis://onboarding/permissions"
        }
    }
}
