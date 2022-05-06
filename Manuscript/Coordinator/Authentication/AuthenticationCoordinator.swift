//
//  AuthenticationCoordinator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class AuthenticationCoordinator: Coordinator, RootProvider, FlowStarter {

    // Coordinator
    weak var parentCoordinator: ApplicationCoordinator? = nil
    var childCoordinators: [Coordinator] = []

    // Local Scope
    private let authenticationComponent: AuthenticationInjector
    private let navigationController: UINavigationController = UINavigationController()

    init(applicationInjector: ApplicationInjector) {
        self.authenticationComponent = AuthenticationInjector(applicationInjector: applicationInjector)
        print("AVERAKEDABRA: ALLOC -> AuthenticationCoordinator")
    }

    func start(with flow: Flowable) {
        handleFlow(flow: flow)
    }

    func navigateToAuthenticationScreen() {
        let vc = AuthenticationViewController(authenticationViewModel: authenticationComponent.provideAuthenticationViewModel())
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func navigateToForgotPasswordScreen() {
        let vc = ForgotPasswordViewController(authenticationViewModel: authenticationComponent.provideAuthenticationViewModel())
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func provideRootViewController() -> UIViewController {
        return navigationController
    }

    func startNewFlow(flow: Flowable) {
        parentCoordinator?.childDidFinish(child: self, flow: flow)
    }

    func goBackToAuthenticationScreen() {
        navigationController.popViewController(animated: true)
    }

    private func handleFlow(flow: Flowable) {
        if let authenticationFlow = flow as? AuthenticationFlow {

            if authenticationFlow == .signIn {
                navigateToAuthenticationScreen()
            }

            if authenticationFlow == .register {
                navigateToAuthenticationScreen()
            }

            if authenticationFlow == .forgotPassword {
                navigateToForgotPasswordScreen()
            }
        }
    }

    deinit {
        print("AVERAKEDABRA: RELEASE -> AuthenticationCoordinator")
    }
}
