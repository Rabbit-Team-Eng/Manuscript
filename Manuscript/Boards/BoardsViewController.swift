//
//  BoardsViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit
import Combine
import Lottie

class BoardsViewController: UIViewController {

    weak var coordinator: BoardsCoordinator? = nil
    
    private let titleTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .headline, weight: .medium)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.text = "You have no boards in this space. Let’s create one!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lottieAnimationView: AnimationView = {
        var animation = AnimationView(animation: Animation.named("107448-human-in-vr-glasses-in-metaverse"))
        animation.loopMode = .loop
        animation.translatesAutoresizingMaskIntoConstraints = false
        return animation
    }()
    
    private let createBoardButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Palette.blue
        button.layer.cornerRadius = 16
        button.setTitle("Create Board", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
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
        createBoardButton.addTarget(self, action: #selector(createBoardButtonDidTap(_:)), for: .touchUpInside)
        
        boardsViewModel.events
            .receive(on: RunLoop.main)
            .sink { completion in } receiveValue: { [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .titleDidFetch(let title):
                self.navigationController?.navigationBar.topItem?.title = title
            case .noBoardIsCreated:
                self.determineBoardPlaceholder(hasBoards: false)
            case .boardsDidFetch(let boards):
                self.determineBoardPlaceholder(hasBoards: true)
                print(boards)
            }
        }
        .store(in: &tokens)

    }
    
    private func determineBoardPlaceholder(hasBoards: Bool) {
        if hasBoards {
            if titleTexLabel.isDescendant(of: view) {
                titleTexLabel.removeFromSuperview()
            }
            if lottieAnimationView.isDescendant(of: view) {
                lottieAnimationView.removeFromSuperview()
            }
            if createBoardButton.isDescendant(of: view) {
                createBoardButton.removeFromSuperview()
            }
        } else {
            view.addSubview(titleTexLabel)
            view.addSubview(lottieAnimationView)
            view.addSubview(createBoardButton)
            
            NSLayoutConstraint.activate([
                titleTexLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                titleTexLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                titleTexLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -62),
                titleTexLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 62),
                titleTexLabel.heightAnchor.constraint(equalToConstant: 48),
                
                lottieAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                lottieAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -62),
                lottieAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 62),
                lottieAnimationView.heightAnchor.constraint(equalToConstant: 170),
                lottieAnimationView.bottomAnchor.constraint(equalTo: titleTexLabel.topAnchor, constant: -32),
                
                createBoardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                createBoardButton.heightAnchor.constraint(equalToConstant: 50),
                createBoardButton.widthAnchor.constraint(equalToConstant: 195),
                createBoardButton.topAnchor.constraint(equalTo: titleTexLabel.bottomAnchor, constant: 50)

            ])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        boardsViewModel.fetchCurrentWorkspace()
        lottieAnimationView.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        

    }
    
    @objc private func createBoardButtonDidTap(_ sender: UIButton) {
        sender.showAnimation { [weak self] in

        }
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
