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
        let vc = BoardsViewController(viewModel: mainComponent.provideMainViewModel())
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func presentBoardCreateEditScreen(state: BoardSheetState) {
        parentCoordinator?.presentBoardCreateEditScreen(state: state)

    }
    
    func presentWorkspaceSelectorScreen() {
        parentCoordinator?.presentWorspaceSelectorScreen()

    }
    
    func dismissAllPresentedControllers() {
        parentCoordinator?.dismissBoardCreationScreen()
        navigateBack()
    }
    
    func dismissWorspaceSelectorScreen() {
        parentCoordinator?.dismissWorspaceSelectorScreen()
    }
    
    func dismissBoardCreationScreen() {
        parentCoordinator?.dismissBoardCreationScreen()
    }
    
    func dismissTaskCreationScreen() {
        parentCoordinator?.dismissTaskCreationSheet()
    }
    
    func navigateToWorksapceDetail(worksapceDetailState: WorksapceDetailState) {
        let vc = WorksapceDetailViewController(mainViewModel: mainComponent.provideMainViewModel(), worksapceDetailState: worksapceDetailState)
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateToBoardDetail() {
        let vc = BoardDetailViewController(mainViewModel: mainComponent.provideMainViewModel())
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goBackFromWorkspaceCreationScreen() {
        navigationController.popViewController(animated: true)
    }
    
    func presentCreateEditTaskSheet(taskDetailState: TaskSheetState) {
        parentCoordinator?.presentTaskDetailScreen(taskDetailState: taskDetailState)
    }
    
    deinit {
        
    }

}
