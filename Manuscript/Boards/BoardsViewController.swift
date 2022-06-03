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
    private let startUpUtils: StartupUtils

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(signOut(_:)))
    }
    
    @objc private func signOut(_ sender: UIBarButtonItem) {
        startUpUtils.deleteAcessToken()
        coordinator?.signeOut()
    }

    init(boardsViewModel: BoardsViewModel, startUpUtils: StartupUtils) {
        self.boardsViewModel = boardsViewModel
        self.startUpUtils = startUpUtils
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
