//
//  OnboardingViewModel.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

class OnboardingViewModel {

    private let startupUtils: StartupUtils

    init(startupUtils: StartupUtils) {
        self.startupUtils = startupUtils
    }

    func onboardingDidFinish() {
        startupUtils.didFinishOnboarding()
    }

    deinit {

    }
}
