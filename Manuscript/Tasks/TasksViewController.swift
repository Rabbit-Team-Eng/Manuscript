//
//  TasksViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class TasksViewController: UIViewController {

    weak var coordinator: TasksCoordinator? = nil

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        NSLayoutConstraint.activate([

        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.lightBlack

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewTask(_:))),
        ]
    }
    
    @objc private func createNewTask(_ sender: UIBarButtonItem) {
        coordinator?.presentTaskCreationSheet()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {

    }
}
