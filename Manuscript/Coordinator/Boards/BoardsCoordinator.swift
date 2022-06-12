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
        let vc = BoardsViewController(boardsViewModel: mainComponent.provideBoardsViewModel(), startUpUtils: mainComponent.provideStartUpUtils(), databaseManager: mainComponent.provideDatabaseManager(), dataProvider: mainComponent.provideDataManager())
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
    
    func navigateToWorksapceDetail(worksapceDetailState: WorksapceDetailState) {
        let vc = WorksapceDetailViewController(workspacesViewModel: mainComponent.provideWorkspacesViewModel(), worksapceDetailState: worksapceDetailState)
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateToBoardDetail(selectedBoard: BoardBusinessModel, selectedWorkspace: WorkspaceBusinessModel) {
        let vc = BoardDetailViewController(selectedWorkspace: selectedWorkspace,
                                           selectedBoard: selectedBoard,
                                           boardViewModel: mainComponent.provideBoardsViewModel())
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goBackFromWorkspaceCreationScreen() {
        navigationController.popViewController(animated: true)
    }
    
    func presentCreateTaskSheet(workspaceBusinessModel: WorkspaceBusinessModel?, selectedBoard: BoardBusinessModel?) {
        parentCoordinator?.presentTaskDetailScreen(taskDetailState: .creation, workspaceBusinessModel: workspaceBusinessModel, selectedBoard: selectedBoard)
    }
    
    deinit {
        
    }

}
