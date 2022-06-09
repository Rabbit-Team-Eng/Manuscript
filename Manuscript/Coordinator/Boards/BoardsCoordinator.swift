//
//  BoardsCoordinator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class BoardsCoordinator: Coordinator, RootProvider, FlowStarter {

    // Coordinator
    weak var parentCoordinator: TabBarCoordinator?
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
    
    func signeOut() {
        parentCoordinator?.signeOut()
    }

    func navigateBack() {
        navigationController.popViewController(animated: true)
    }

    func navigateToBoardsScreen() {
        let vc = BoardsViewController(boardsViewModel: mainComponent.provideBoardsViewModel(), startUpUtils: mainComponent.provideStartUpUtils(), databaseManager: mainComponent.provideDatabaseManager())
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func presentCreateBoardScreen() {
        parentCoordinator?.presentCreateBoardScreen()

    }
    
    func presentWorkspaceSelectorScreen() {
        parentCoordinator?.presentWorspaceSelectorScreen()

    }
    
    func dismissBoardCreationScreen() {
        parentCoordinator?.dismissBoardCreationScreen()
    }
    
    func pushCreateWorksapceViewController() {
        let vc = WorksapceCreateViewController(workspacesViewModel: mainComponent.provideWorkspacesViewModel())
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateToBoardDetail(withId: String) {
        let vc = BoardDetailViewController(boardId: withId)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func presentCreateTaskSheet(boardId: String) {
        parentCoordinator?.presentCreateTaskScreen()
    }
    
    deinit {
        print("AVERAKEDABRA: RELEASE -> BoardsCoordinator")
    }

}
