//
//  TabBarCoordinator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit
import Combine

class TabBarCoordinator: NSObject, Coordinator, RootProvider, UITabBarControllerDelegate {
    // Coordinator
    weak var parentCoordinator: ApplicationCoordinator? = nil
    var childCoordinators: [Coordinator] = []

    // Local Scope
    private let mainInjector: MainInjector
    private var tokens: Set<AnyCancellable> = []
    
    // children
    var boardsCoordinator: BoardsCoordinator!
    var tasksCoordinator: TasksCoordinator!

    private let mainTabBarController: UITabBarController = UITabBarController()

    init(applicationInjector: ApplicationInjector) {
        self.mainInjector = MainInjector(applicationInjector: applicationInjector)
        super.init()
        print("AVERAKEDABRA: ALLOC -> TabBarCoordinator")
        mainTabBarController.delegate = self
        
        let cloud = mainInjector.provideCloudSync()
        cloud.syncronize()

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
        boardsCoordinator = BoardsCoordinator(mainComponent: mainInjector)
        tasksCoordinator = TasksCoordinator(mainComponent: mainInjector)

        boardsCoordinator.parentCoordinator = self
        tasksCoordinator.parentCoordinator = self

        childCoordinators.append(boardsCoordinator)
        childCoordinators.append(tasksCoordinator)

        let boardsRoot = boardsCoordinator.provideRootViewController()
        let tasksRoot = tasksCoordinator.provideRootViewController()
        boardsRoot.tabBarItem = UITabBarItem(title: "Boards", image: UIImage(systemName: "checkerboard.rectangle"), selectedImage: UIImage(systemName: "checkerboard.rectangle"))
        tasksRoot.tabBarItem = UITabBarItem(title: "Tasks", image: UIImage(systemName: "square.and.pencil"), selectedImage: UIImage(systemName: "square.and.pencil"))
        mainTabBarController.setViewControllers([boardsRoot, tasksRoot], animated: false)

        boardsCoordinator.start(with: BoardsFlow.boards)
        tasksCoordinator.start(with: TasksFlow.tasks)
    }
    
    func presentCreateBoardScreen() {
        let vc = BoardCreateViewController(boardsViewModel: mainInjector.provideBoardsViewModel())
        vc.modalPresentationStyle = .pageSheet
        vc.parentCoordinator = self
        if let sheet = vc.sheetPresentationController {
             sheet.detents = [.medium(), .large()]
         }
        mainTabBarController.present(vc, animated: true, completion: nil)

    }
    
    func presentCreateTaskScreen(withSelectedBoardId: String? = nil) {
        let vc = TaskCreateViewController()
        vc.modalPresentationStyle = .pageSheet
        vc.coordinator = self
        if let sheet = vc.sheetPresentationController {
             sheet.detents = [.medium(), .large()]
         }
        mainTabBarController.present(vc, animated: true, completion: nil)
    }
    
    func presentWorspaceSelectorScreen() {
        let vc = WorkspaceSelectorViewController(workspacesViewModel: mainInjector.provideWorkspacesViewModel())
        vc.parentCoordinator = self
                                                 
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
             sheet.detents = [.medium()]
         }
        mainTabBarController.present(navController, animated: true, completion: nil)

    }
    
    func dismissTaskCreationSheet() {
        mainTabBarController.dismiss(animated: true)
    }
    
    func dismissWorspaceSelectorScreen() {
        mainTabBarController.dismiss(animated: true)
    }
    
    func dismissBoardCreationScreen() {
        mainTabBarController.dismiss(animated: true)
    }
    
    func navigateToWorkspaceCreateViewConntroller() {
        mainTabBarController.dismiss(animated: true) {
            self.boardsCoordinator.pushCreateWorksapceViewController()
        }
    }
    
    deinit {
        print("AVERAKEDABRA: RELEASE -> TabBarCoordinator")
    }
}
