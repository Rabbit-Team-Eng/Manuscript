//
//  ApplicationCoordinator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class ApplicationCoordinator: Coordinator, FlowFinisher {

    var childCoordinators: [Coordinator] = []
    private let applicationMainWindow: UIWindow
    private let startupUtils: StartupUtils
    private let injector: ApplicationInjector

    init(applicationMainWindow: UIWindow) {
        self.applicationMainWindow = applicationMainWindow
        self.injector = ApplicationInjector()
        self.startupUtils = injector.provideStartupUtils()
    }

    func start(with flow: Flowable) {
        if startupUtils.getAccessToken() != "" {
            print("\nAccess Token: \(startupUtils.getAccessToken())\n")
            handleFlow(flow: ApplicationFlow.main(mainFLow: TabBarFlow.boards))
        } else {
            if startupUtils.isOnboarded() {
                handleFlow(flow: ApplicationFlow.authentication(authenticationFlow: .signIn))
            } else {
                // AppDelegate by default send to onboarding
                handleFlow(flow: flow)
            }
        }
    }

    func navigateToTabBarFlow(flow: TabBarFlow) {
        let coordinator = TabBarCoordinator(applicationInjector: injector)
        applicationMainWindow.rootViewController = coordinator.provideRootViewController()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start(with: flow)
    }


    func navigateToAuthenticationFlow(flow: AuthenticationFlow) {
        let coordinator = AuthenticationCoordinator(applicationInjector: injector)
        applicationMainWindow.rootViewController = coordinator.provideRootViewController()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start(with: flow)
    }

    func navigateToOnboardingFlow(flow: OnboardingFlow) {
        let coordinator = OnboardingCoordinator(applicationInjector: injector)
        applicationMainWindow.rootViewController = coordinator.provideRootViewController()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start(with: flow)
    }

    func childDidFinish(child: Coordinator, flow: Flowable) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
        handleFlow(flow: flow)
    }

    private func handleFlow(flow: Flowable) {
        if let applicationFlow = flow as? ApplicationFlow {
            switch applicationFlow {
            case .main(let mainFLow):
                navigateToTabBarFlow(flow: mainFLow)
            case .onboarding(let onboardingFlow):
                navigateToOnboardingFlow(flow: onboardingFlow)
            case .authentication(let authenticationFlow):
                navigateToAuthenticationFlow(flow: authenticationFlow)
            }
        }
    }

    deinit {

    }
}
