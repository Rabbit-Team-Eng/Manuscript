//
//  MainInjector.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class MainInjector {
    
    // Local Scope
    private var coreDataStack: CoreDataStack? = nil
    private var workspaceService: WorkspaceService? = nil
    private var dataManager: DataProvider? = nil
    private var boardsViewModel: BoardsViewModel? = nil
    private var workspaceCoreDatabaseManager: WorkspaceCoreDataManager? = nil
    private var workspaceSyncronizer: WorkspaceSyncronizer? = nil

    // Injected from Application Scope
    private let startupUtils: StartupUtils
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    init(applicationInjector: ApplicationInjector) {
        self.startupUtils = applicationInjector.provideStartupUtils()
        self.jsonDecoder = applicationInjector.provideJsonDecoder()
        self.jsonEncoder = applicationInjector.provideJsonEncoder()
        print("AVERAKEDABRA: ALLOC -> MainInjector")
    }
    
    func provideWorkspaceSyncronizer() -> WorkspaceSyncronizer {
        if workspaceSyncronizer != nil {
            return workspaceSyncronizer!
        } else {
            workspaceSyncronizer = WorkspaceSyncronizer(coreDataStack: provideCoreDataStack(),
                                                        workspaceService: provideWorkspaceService(),
                                                        startupUtils: startupUtils,
                                                        workspaceCoreDataManager: provideWorkspaceCoreDataManager())
            return workspaceSyncronizer!
        }
    }

    func provideWorkspaceCoreDataManager() -> WorkspaceCoreDataManager {
        if workspaceCoreDatabaseManager != nil {
            return workspaceCoreDatabaseManager!
        } else {
            workspaceCoreDatabaseManager = WorkspaceCoreDataManager(coreDataStack: provideCoreDataStack())
            return workspaceCoreDatabaseManager!
        }
    }
    
    func provideBoardsViewModel() -> BoardsViewModel {
        if boardsViewModel != nil {
            return boardsViewModel!
        } else {
            boardsViewModel = BoardsViewModel(dataProvider: provideDataManager())
            return boardsViewModel!
        }
    }
    
    func provideCoreDataStack() -> CoreDataStack {
        if coreDataStack != nil {
            return coreDataStack!
        } else {
            coreDataStack = CoreDataStack()
            return coreDataStack!
        }
    }
    
    func provideWorkspaceService() -> WorkspaceService {
        if workspaceService != nil {
            return workspaceService!
        } else {
            workspaceService = WorkspaceService(accessToken: startupUtils.getAccessToken(), environment: startupUtils.provideEnvironment(), jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
            return workspaceService!
        }
    }
    
    func provideDataManager() -> DataProvider {
        if dataManager != nil {
            return dataManager!
        } else {
            dataManager = DataProvider(coreDataStack: provideCoreDataStack())
            return dataManager!
        }
    }
    
    func provideStartUpUtils() -> StartupUtils {
        return startupUtils
    }

    deinit {
        print("AVERAKEDABRA: RELEASE -> MainInjector")
    }
}
