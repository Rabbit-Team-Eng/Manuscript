//
//  BoardDetailViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit
import Combine

class BoardDetailViewController: UIViewController {
    
    weak var coordinator: BoardsCoordinator? = nil

    private let selectedWorkspace: WorkspaceBusinessModel
    private let selectedBoard: BoardBusinessModel
    private let boardViewModel: BoardsViewModel
    private var tokens: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.square"), style: .plain, target: self, action: #selector(backButtonDidTap(_:)))
 
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewTaskButtonDidTap(_:))),
            UIBarButtonItem(image: UIImage(systemName: "slider.vertical.3"), style: .plain, target: self, action: #selector(editCurrentBoardButtonDidTap(_:))),
        ]
        
        
        self.navigationItem.title = selectedBoard.title
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc private func backButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.goBackFromWorkspaceCreationScreen()
    }
    
    
    @objc private func createNewTaskButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.presentCreateTaskSheet(workspaceBusinessModel: selectedWorkspace, selectedBoard: selectedBoard)
    }
    
    @objc private func editCurrentBoardButtonDidTap(_ sender: UIBarButtonItem) {
        
    }
    
    init(selectedWorkspace: WorkspaceBusinessModel, selectedBoard: BoardBusinessModel, boardViewModel: BoardsViewModel) {
        self.selectedWorkspace = selectedWorkspace
        self.selectedBoard = selectedBoard
        self.boardViewModel = boardViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {

    }

}
