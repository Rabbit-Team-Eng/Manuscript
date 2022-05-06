//
//  OnboardingCoordinator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class OnboardingCoordinator: Coordinator, RootProvider, FlowStarter {

    // Coordinator
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: ApplicationCoordinator? = nil

    // Local Scope
    private let onboardingInjector: OnboardingInjector
    private let navigationController: UINavigationController = UINavigationController()

    init(applicationInjector: ApplicationInjector) {
        self.onboardingInjector = OnboardingInjector(applicationInjector: applicationInjector)
        print("AVERAKEDABRA: ALLOC -> OnboardingCoordinator")
    }

    func start(with flow: Flowable) {
        handleFlow(flow: flow)
    }

    func provideRootViewController() -> UIViewController {
        return navigationController
    }

    func startNewFlow(flow: Flowable) {
        parentCoordinator?.childDidFinish(child: self, flow: flow)
    }

    func navigateWelcomeScreen() {
        let vc = OnboardingViewController(onboardingViewModel: onboardingInjector.provideOnboardingViewModel())
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func navigateToPermissionsScreen() {
        let vc = PermissionsViewController(onboardingViewModel: onboardingInjector.provideOnboardingViewModel())
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    private func handleFlow(flow: Flowable) {
        if let onboarding = flow as? OnboardingFlow {

            if onboarding == .welcome {
                navigateWelcomeScreen()
            }

            if onboarding == .permissions {
                navigateToPermissionsScreen()
            }
        }
    }

    deinit {
        print("AVERAKEDABRA: RELEASE -> OnboardingCoordinator")
    }
}
