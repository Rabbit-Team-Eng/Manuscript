//
//  BoardsViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class BoardsViewController: UIViewController {

    weak var coordinator: BoardsCoordinator? = nil
    
    private let boardsViewModel: BoardsViewModel

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
    }

    init(boardsViewModel: BoardsViewModel) {
        self.boardsViewModel = boardsViewModel
        print("AVERAKEDABRA: ALLOC -> BoardsViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {
        print("AVERAKEDABRA: RELEASE -> BoardsViewController")
    }
}
