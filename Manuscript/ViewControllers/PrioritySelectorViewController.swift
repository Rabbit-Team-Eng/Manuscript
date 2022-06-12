//
//  PrioritySelectorViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import UIKit

class PrioritySelectorViewController: UIViewController {
    
    weak var parentCoordinator: TabBarCoordinator? = nil

    private let selectNewPriorityButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.title = "Set Priority"
        button.contentHorizontalAlignment = .center
        button.configuration?.baseBackgroundColor = Palette.blue
        button.setTitleColor(Palette.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.mediumDarkGray
        
        view.addSubview(selectNewPriorityButton)
        
        selectNewPriorityButton.addTarget(self, action: #selector(newPriorityDidSelected(_:)), for: .touchUpInside)
    }
    
    @objc private func newPriorityDidSelected(_ sender: UIButton) {
        parentCoordinator?.dismissPrioritySheet()
        boardViewModel.newPriorityDidSet()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            selectNewPriorityButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            selectNewPriorityButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            selectNewPriorityButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            selectNewPriorityButton.heightAnchor.constraint(equalToConstant: 50)
        
        ])
    }
    
    let boardViewModel: BoardsViewModel

    init(boardViewModel: BoardsViewModel) {
        self.boardViewModel = boardViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {

    }


}
