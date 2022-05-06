//
//  BoardsViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class BoardsViewController: UIViewController {

    weak var coordinator: BoardsCoordinator? = nil

    let mainButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("This is frickin Boards flow | Go to Detail", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        NSLayoutConstraint.activate([
            mainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainButton.heightAnchor.constraint(equalToConstant: 40),
            mainButton.widthAnchor.constraint(equalToConstant: 300),
        ])
    }

    @objc func mainButtonDidTap(sender: UIButton) {
        coordinator?.navigateToBoardDetailScreen()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(mainButton)
        mainButton.addTarget(self, action: #selector(mainButtonDidTap), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: #selector(createNewWorkspaceButtonDidTap))
    }

    @objc func createNewWorkspaceButtonDidTap(_ sender: UIBarButtonItem) {

    }

    init() {
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
