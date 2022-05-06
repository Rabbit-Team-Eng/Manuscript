//
//  OnboardingInjector.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class OnboardingInjector {

    // Injected from Application Scope
    private let startupUtils: StartupUtils

    // Local
    private var onboardingViewModel: OnboardingViewModel? = nil

    init(applicationInjector: ApplicationInjector) {
        self.startupUtils = applicationInjector.provideStartupUtils()
        print("AVERAKEDABRA: ALLOC -> OnboardingInjector")
    }

    func provideOnboardingViewModel() -> OnboardingViewModel {
        if onboardingViewModel != nil {
            return onboardingViewModel!
        } else {
            onboardingViewModel = OnboardingViewModel(startupUtils: startupUtils)
            return onboardingViewModel!
        }
    }

    deinit {
        print("AVERAKEDABRA: RELEASE -> OnboardingInjector")
    }
}
