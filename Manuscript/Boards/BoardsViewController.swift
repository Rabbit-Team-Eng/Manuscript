//
//  BoardsViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit
import Combine

class BoardsViewController: UIViewController {

    weak var coordinator: BoardsCoordinator? = nil
    
    private let boardsViewModel: BoardsViewModel
    private let startUpUtils: StartupUtils
    private var tokens: Set<AnyCancellable> = []

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(signOut(_:)))
        
        boardsViewModel.events.sink { completion in } receiveValue: { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .titleDidFetch(let title):
                DispatchQueue.main.async {  [weak self] in
                    guard let self = self else { return }
                    self.navigationController?.navigationBar.topItem?.title = title
                }
            case .noBoardIsCreated:
                print("No Boards")
            case .boardsDidFetch(let boards):
                print(boards)
            }
        }
        .store(in: &tokens)

        boardsViewModel.fetchCurrentWorkspace()

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
