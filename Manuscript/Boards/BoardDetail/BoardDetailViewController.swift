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

    private let boardId: String
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
        
        boardViewModel.events
            .receive(on: RunLoop.main)
            .sink { [weak self] event in guard let self = self else { return }
            
            if case .boardDetailDidFetch(let board) = event {
                self.navigationItem.title = board.title
            }

        }
        .store(in: &tokens)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        boardViewModel.fetchCurrentBoard(id: boardId)
    }
    
    @objc private func backButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.goBackFromWorkspaceCreationScreen()
    }
    
    
    @objc private func createNewTaskButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.presentCreateTaskSheet(boardId: boardId)
    }
    
    @objc private func editCurrentBoardButtonDidTap(_ sender: UIBarButtonItem) {
        
    }
    
    init(boardId: String, boardViewModel: BoardsViewModel) {
        self.boardId = boardId
        self.boardViewModel = boardViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        print("AVERAKEDABRA: RELEASE -> BoardDetailViewController")
    }

}
