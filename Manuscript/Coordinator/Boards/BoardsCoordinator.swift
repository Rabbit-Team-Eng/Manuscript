//
//  BoardsCoordinator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class BoardsCoordinator: Coordinator, RootProvider, FlowStarter {

    // Coordinator
    weak var parentCoordinator: TabBarCoordinator? = nil
    var childCoordinators: [Coordinator] = []

    // Injected
    private let mainComponent: MainInjector

    private let navigationController: UINavigationController = UINavigationController()

    init(mainComponent: MainInjector) {
        self.mainComponent = mainComponent
        print("AVERAKEDABRA: ALLOC -> BoardsCoordinator")
    }

    func start(with flow: Flowable) {
        navigateToBoardsScreen()
    }

    func provideRootViewController() -> UIViewController {
        return navigationController
    }

    func startNewFlow(flow: Flowable) {

    }

    func navigateBack() {
        navigationController.popViewController(animated: true)
    }

    func navigateToBoardsScreen() {
        let vc = BoardsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func navigateToBoardDetailScreen(isTabBarOn: Bool = false) {

        let vc = BoardDetailViewController()
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

}
