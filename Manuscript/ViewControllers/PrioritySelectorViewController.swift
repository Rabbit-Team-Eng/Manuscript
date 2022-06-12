//
//  PrioritySelectorViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/12/22.
//

import UIKit

class PrioritySelectorViewController: UIViewController {
    
    weak var parentCoordinator: TabBarCoordinator? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
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
