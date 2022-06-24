//
//  TasksCoordinator.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class TasksCoordinator: Coordinator, RootProvider, FlowStarter {

    // Coordinator
    weak var parentCoordinator: TabBarCoordinator? = nil
    var childCoordinators: [Coordinator] = []

    // Injected
    private let mainComponent: MainInjector

    private let navigationController: UINavigationController = UINavigationController()

    init(mainComponent: MainInjector) {
        self.mainComponent = mainComponent
    }

    func start(with flow: Flowable) {
        navigateToTasksScreen()
    }

    func provideRootViewController() -> UIViewController {
        return navigationController
    }
    
    func presentTaskDetailSheet(taskDetailState: TaskSheetState) {
        parentCoordinator?.presentTaskDetailScreen(taskDetailState: taskDetailState)
    }

    func startNewFlow(flow: Flowable) {

    }

    func navigateToTasksScreen() {
        let vc = TasksViewController(dataProvider: mainComponent.provideDataManager())
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    deinit {

    }
}
