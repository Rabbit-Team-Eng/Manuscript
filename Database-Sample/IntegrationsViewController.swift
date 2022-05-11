//
//  ViewController.swift
//  Database-Sample
//
//  Created by Tigran Ghazinyan on 5/9/22.
//

import UIKit
import CoreData
import Combine

class IntegrationsViewController: UIViewController {
    
    private var viewModel: ViewModel? = nil
    private var tokens: Set<AnyCancellable> = []

    let signInButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor(hex: "#6A67CE")
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign In", for: .normal)
        return button
    }()
    
    let refreshButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor(hex: "#947EC3")
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Refresh the Entire DB!", for: .normal)
        return button
    }()
    
    let printLocalDB: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor(hex: "#B689C0")
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Print all local DB!", for: .normal)
        return button
    }()
    
    let removeLocalDB: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor(hex: "#6A67CE")
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Remove all local DB!", for: .normal)
        return button
    }()
    
    let insertIntoServer: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor(hex: "#947EC3")
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Insert into server", for: .normal)
        return button
    }()
    
    let insertIntoLocal: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor(hex: "#B689C0")
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Insert into Local", for: .normal)
        return button
    }()
    
    let getAllBoards: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = UIColor(hex: "#B689C0")
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Print All local Boards", for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#15133C")
        view.addSubview(signInButton)
        view.addSubview(refreshButton)
        view.addSubview(printLocalDB)
        view.addSubview(removeLocalDB)
        view.addSubview(insertIntoServer)
        view.addSubview(insertIntoLocal)
        view.addSubview(getAllBoards)

        let startupUtils = StartupUtils()
        let coreDataStack = CoreDataStack()
        let workspaceService = WorkspaceService(accessToken: startupUtils.getAccessToken(), environment: .production, jsonEncoder: JSONEncoder(), jsonDecoder: JSONDecoder())
        let boardSyncronizer = BoardSyncronizer(coreDataStack: coreDataStack, startupUtils: startupUtils)
        let boardsService = BoardService(accessToken: startupUtils.getAccessToken(), environment: .production, jsonEncoder: JSONEncoder(), jsonDecoder: JSONDecoder())
        let dataProvider = DataProvider(coreDataStack: coreDataStack)
        let authManager = AuthenticationManager(environment: .production, jsonDecoder: JSONDecoder(), jsonEncoder: JSONEncoder())
        let workspaceCoreDataManager = WorkspaceCoreDataManager(coreDataStack: coreDataStack)
        let workspaceSyncronizer = WorkspaceSyncronizer(coreDataStack: coreDataStack, workspaceService: workspaceService, startupUtils: startupUtils, workspaceCoreDataManager: workspaceCoreDataManager)
        
        
        viewModel = ViewModel(coreDataStack: coreDataStack,
                              workspaceService: workspaceService,
                              boardsService: boardsService,
                              dataProvider: dataProvider,
                              authenticationManager: authManager,
                              boardsSyncronizer: boardSyncronizer,
                              workspaceSyncronizer: workspaceSyncronizer,
                              startupUtils: startupUtils)
        
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        printLocalDB.addTarget(self, action: #selector(printLocalDBDidTap), for: .touchUpInside)
        removeLocalDB.addTarget(self, action: #selector(removeLocalDBDidTap), for: .touchUpInside)
        insertIntoServer.addTarget(self, action: #selector(insertIntoServerDidTap), for: .touchUpInside)
        insertIntoLocal.addTarget(self, action: #selector(insertIntoLocalDidTap), for: .touchUpInside)
        getAllBoards.addTarget(self, action: #selector(getAllBoardsButtonDidTap), for: .touchUpInside)

        guard let vm = viewModel else { return }
        
        vm.state.sink { completion in } receiveValue: { event in
            if event == .didSignedIn {
                print("The User Did Singe In!")
            }
            
            if event == .didRefreshedTheDB {
                print("The User Did Refresh the Entire DB!")
            }
        }
        .store(in: &tokens)

    }
    
    @objc func getAllBoardsButtonDidTap(_ sender: UIButton) {
        viewModel?.getAllBoards()
    }
    
    @objc func refresh(_ sender: UIButton) {
        viewModel?.syncDatabaseInBackground()
    }
    
    @objc func signIn(_ sender: UIButton) {
        viewModel?.signIn(email: "shady@test.com", password: "Pass123!")
    }
    
    @objc func printLocalDBDidTap(_ sender: UIButton) {
        viewModel?.printAllLocalDB()
    }
    
    @objc func removeLocalDBDidTap(_ sender: UIButton) {
        viewModel?.removeLocalDB()
    }
    
    @objc func insertIntoServerDidTap(_ sender: UIButton) {
        viewModel?.insertIntoServer()
    }
    
    @objc func insertIntoLocalDidTap(_ sender: UIButton) {
        viewModel?.insertIntoLocal()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            signInButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            signInButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            signInButton.heightAnchor.constraint(equalToConstant: 40),
            
            refreshButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 16),
            refreshButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            refreshButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            refreshButton.heightAnchor.constraint(equalToConstant: 40),
            
            printLocalDB.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 16),
            printLocalDB.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            printLocalDB.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            printLocalDB.heightAnchor.constraint(equalToConstant: 40),
            
            removeLocalDB.topAnchor.constraint(equalTo: printLocalDB.bottomAnchor, constant: 16),
            removeLocalDB.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            removeLocalDB.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            removeLocalDB.heightAnchor.constraint(equalToConstant: 40),
            
            insertIntoServer.topAnchor.constraint(equalTo: removeLocalDB.bottomAnchor, constant: 16),
            insertIntoServer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            insertIntoServer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            insertIntoServer.heightAnchor.constraint(equalToConstant: 40),
            
            insertIntoLocal.topAnchor.constraint(equalTo: insertIntoServer.bottomAnchor, constant: 16),
            insertIntoLocal.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            insertIntoLocal.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            insertIntoLocal.heightAnchor.constraint(equalToConstant: 40),
            
            getAllBoards.topAnchor.constraint(equalTo: insertIntoLocal.bottomAnchor, constant: 16),
            getAllBoards.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            getAllBoards.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            getAllBoards.heightAnchor.constraint(equalToConstant: 40),
        ])
    }


}


