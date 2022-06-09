//
//  BoardDetailViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit

class BoardDetailViewController: UIViewController {
    
    weak var coordinator: BoardsCoordinator? = nil

    private let boardId: String

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewTaskButtonDidTap(_:))),
            UIBarButtonItem(image: UIImage(systemName: "slider.vertical.3"), style: .plain, target: self, action: #selector(editCurrentBoardButtonDidTap(_:))),
        ]
    }
    
    @objc private func createNewTaskButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.presentCreateTaskSheet(boardId: boardId)
    }
    
    @objc private func editCurrentBoardButtonDidTap(_ sender: UIBarButtonItem) {
        
    }
    
    init(boardId: String) {
        self.boardId = boardId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        print("AVERAKEDABRA: RELEASE -> BoardDetailViewController")
    }

}
