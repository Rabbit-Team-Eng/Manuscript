//
//  BoardDetailViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class BoardDetailViewController: UIViewController {

    weak var coordinator: BoardsCoordinator? = nil

    let mainButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("This board Detail | Back to Boards on Tab Bar", for: .normal)
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
        coordinator?.navigateBack()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.hidesBottomBarWhenPushed = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        view.addSubview(mainButton)
        mainButton.addTarget(self, action: #selector(mainButtonDidTap), for: .touchUpInside)
    }

    init() {
        print("AVERAKEDABRA: ALLOC -> BoardDetailViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {
        print("AVERAKEDABRA: RELEASE -> BoardDetailViewController")
    }
}
