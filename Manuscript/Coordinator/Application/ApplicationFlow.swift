//
//  ApplicationFlow.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

enum ApplicationFlow: Flowable {

    case onboarding(onboardingFlow: OnboardingFlow)
    case authentication(authenticationFlow: AuthenticationFlow)
    case main(mainFLow: TabBarFlow)

    func getNavigationEntryDeepLink() -> String {
        switch self {
        case .onboarding(let onboardingFlow):
            return onboardingFlow.getNavigationEntryDeepLink()
        case .authentication(let authenticationFlow):
            return authenticationFlow.getNavigationEntryDeepLink()
        case .main(let mainFLow):
            return mainFLow.getNavigationEntryDeepLink()
        }
    }

}
