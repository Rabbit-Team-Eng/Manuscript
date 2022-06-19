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
    private var taskService: TaskService? = nil
    private var dataManager: DataProvider? = nil
    private var boardsViewModel: BoardsViewModel? = nil
    private var workspacesViewModel: WorkspacesViewModel? = nil
    private var workspaceCoreDatabaseManager: WorkspaceCoreDataManager? = nil
    private var workspaceSyncronizer: WorkspaceSyncronizer? = nil
    private var taskSyncronizer: TaskSyncronizer? = nil
    private var taskCoreDataManager: TaskCoreDataManager? = nil
    private var boardService: BoardService? = nil
    private var cloudSync: CloudSync? = nil
    private var boardSyncronizer: BoardSyncronizer? = nil
    private var boardCoreDataManager: BoardCoreDataManager? = nil
    private var databaseManager: DatabaseManager? = nil
    private var boardCreator: BoardCreator? = nil
    private var taskCreator: TaskCreator? = nil
    private var signalRManager: SignalRManager? = nil
    private var socketIO: SignalRConnectionListener? = nil
    private var memberCoreDataManager: MemberCoreDataManager? = nil
    
    // Injected from Application Scope
    private let startupUtils: StartupUtils
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    init(applicationInjector: ApplicationInjector) {
        self.startupUtils = applicationInjector.provideStartupUtils()
        self.jsonDecoder = applicationInjector.provideJsonDecoder()
        self.jsonEncoder = applicationInjector.provideJsonEncoder()
    }
    
    func provideTaskService() -> TaskService {
        if taskService != nil {
            return taskService!
        } else {
            taskService = TaskService(accessToken: startupUtils.getAccessToken(), environment: startupUtils.provideEnvironment(), jsonEncoder: jsonEncoder, jsonDecoder: jsonDecoder)
            return taskService!
        }
    }
    
    func provideSocketIO() -> SignalRConnectionListener {
        if socketIO != nil {
            return socketIO!
        } else {
            socketIO = SignalRConnectionListener()
            return socketIO!
        }
    }
    
    func provideSignalRManager() -> SignalRManager {
        if signalRManager != nil {
            return signalRManager!
        } else {
            signalRManager = SignalRManager(delegate: provideSocketIO(), startupUtils: provideStartUpUtils(), cloud: provideCloudSync())
            return signalRManager!
        }
    }
    
    func provideTaskCreator() -> TaskCreator {
        if taskCreator != nil {
            return taskCreator!
        } else {
            taskCreator = TaskCreator(taskService: provideTaskService(), database: provideCoreDataStack(), signalRManager: provideSignalRManager(), dataProvider: provideDataManager())
            return taskCreator!
        }
    }
    
    func provideBoardCreator() -> BoardCreator {
        if boardCreator != nil {
            return boardCreator!
        } else {
            boardCreator = BoardCreator(boardService: provideBoardService(), database: provideCoreDataStack(), signalRManager: provideSignalRManager(), dataProvider: provideDataManager())
            return boardCreator!
        }
    }
    
    func provideDatabaseManager() -> DatabaseManager {
        if databaseManager != nil {
            return databaseManager!
        } else {
            databaseManager = DatabaseManager(coreDataStack: provideCoreDataStack())
            return databaseManager!
        }
    }
    
    func provideBoardCoreDataManager() -> BoardCoreDataManager {
        if boardCoreDataManager != nil {
            return boardCoreDataManager!
        } else {
            boardCoreDataManager = BoardCoreDataManager(coreDataStack: provideCoreDataStack())
            return boardCoreDataManager!
        }
    }
    
    func provideBoardSyncronizer() -> BoardSyncronizer {
        if boardSyncronizer != nil {
            return boardSyncronizer!
        } else {
            boardSyncronizer = BoardSyncronizer(coreDataStack: provideCoreDataStack(),
                                                startupUtils: provideStartUpUtils(),
                                                boardCoreDataManager: provideBoardCoreDataManager(),
                                                boardService: provideBoardService())
            return boardSyncronizer!
        }
    }
    
    func provideTaskCoreDataManager() -> TaskCoreDataManager {
        if taskCoreDataManager != nil {
            return taskCoreDataManager!
        } else {
            taskCoreDataManager = TaskCoreDataManager(coreDataStack: provideCoreDataStack())
            return taskCoreDataManager!
        }
    }
    

    func provideTaskSyncronizer() -> TaskSyncronizer {
        if taskSyncronizer != nil {
            return taskSyncronizer!
        } else {
            taskSyncronizer = TaskSyncronizer(coreDataStack: provideCoreDataStack(),
                                              startupUtils: provideStartUpUtils(),
                                              taskCoreDataManager: provideTaskCoreDataManager(),
                                              taskService: provideTaskService())
            return taskSyncronizer!
        }
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
    
    func provideWorkspacesViewModel() -> WorkspacesViewModel {
        if workspacesViewModel != nil {
            return workspacesViewModel!
        } else {
            workspacesViewModel = WorkspacesViewModel(dataProvider: provideDataManager())
            return workspacesViewModel!
        }
    }
    
    func provideBoardsViewModel() -> BoardsViewModel {
        if boardsViewModel != nil {
            return boardsViewModel!
        } else {
            boardsViewModel = BoardsViewModel(dataProvider: provideDataManager(), boardCreator: provideBoardCreator(), taskCreator: provideTaskCreator(), cloudSync: provideCloudSync())
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
    
    func provideBoardService() -> BoardService {
        if boardService != nil {
            return boardService!
        } else {
            boardService = BoardService(accessToken: startupUtils.getAccessToken(),
                                                       environment: startupUtils.provideEnvironment(),
                                                       jsonEncoder: jsonEncoder,
                                                       jsonDecoder: jsonDecoder)
            return boardService!
        }
    }
    
    func provideMemberCoreDataManager() -> MemberCoreDataManager {
        if memberCoreDataManager != nil {
            return memberCoreDataManager!
        } else {
            memberCoreDataManager = MemberCoreDataManager(coreDataStack: provideCoreDataStack())
            return memberCoreDataManager!
        }
    }
    
    func provideCloudSync() -> CloudSync {
        if cloudSync != nil {
            return cloudSync!
        } else {
            cloudSync = CloudSync(workspaceService: provideWorkspaceService(),
                                  boardsService: provideBoardService(), membersCoreDataManager: provideMemberCoreDataManager(),
                                  workspaceSyncronizer: provideWorkspaceSyncronizer(),
                                  dataProvider: provideDataManager(),
                                  boardSyncronizer: provideBoardSyncronizer(),
                                  taskSyncronizer: provideTaskSyncronizer())
            return cloudSync!
        }
    }
    
    func provideStartUpUtils() -> StartupUtils {
        return startupUtils
    }

    deinit {
        print("DEALLOC -> MainInjector")
    }
}
