//
//  TabBarCoordinator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class TabBarCoordinator: NSObject, Coordinator, RootProvider, UITabBarControllerDelegate {
    // Coordinator
    weak var parentCoordinator: ApplicationCoordinator? = nil
    var childCoordinators: [Coordinator] = []

    // Local Scope
    private let mainInjector: MainInjector

    private let mainTabBarController: UITabBarController = UITabBarController()

    override init() {
        self.mainInjector = MainInjector()
        super.init()
        print("AVERAKEDABRA: ALLOC -> TabBarCoordinator")
        mainTabBarController.delegate = self
    }

    func start(with flow: Flowable) {
        addAllTabBarControllers()
    }

    func provideRootViewController() -> UIViewController {
        return mainTabBarController
    }

    // If need to have custom behavior when tab is selected
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    func signeOut() {
        parentCoordinator?.childDidFinish(child: self, flow: ApplicationFlow.authentication(authenticationFlow: AuthenticationFlow.signIn))
    }

    private func addAllTabBarControllers() {
        let boardsCoordinator = BoardsCoordinator(mainComponent: mainInjector)
        let tasksCoordinator = TasksCoordinator(mainComponent: mainInjector)

        boardsCoordinator.parentCoordinator = self
        tasksCoordinator.parentCoordinator = self

        childCoordinators.append(boardsCoordinator)
        childCoordinators.append(tasksCoordinator)

        let boardsRoot = boardsCoordinator.provideRootViewController()
        let tasksRoot = tasksCoordinator.provideRootViewController()
        boardsRoot.tabBarItem = mainInjector.provideBoardsTabBarItem()
        tasksRoot.tabBarItem = mainInjector.provideTasksTabBarItem()
        mainTabBarController.setViewControllers([boardsRoot, tasksRoot], animated: false)

        boardsCoordinator.start(with: BoardsFlow.boards)
        tasksCoordinator.start(with: TasksFlow.tasks)
    }
    
    deinit {
        print("AVERAKEDABRA: RELEASE -> TabBarCoordinator")
    }
}
