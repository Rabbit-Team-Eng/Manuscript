//
//  WorksapceCreateViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit

enum WorksapceDetailState {
    case create
    case edit(workspace: WorkspaceBusinessModel)
    case view(workspace: WorkspaceBusinessModel)
}

class WorksapceDetailViewController: UIViewController {
    
    private let workspacesViewModel: WorkspacesViewModel
    private let worksapceDetailState: WorksapceDetailState
    
    weak var coordinator: BoardsCoordinator? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.gray
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward.square"), style: .plain, target: self, action: #selector(backButtonDidTap(_:)))
        
        if case .create = worksapceDetailState {
            navigationItem.title = "Create new workspace"
        }
        
        if case .view(let workspace) = worksapceDetailState {
            navigationItem.title = workspace.title
        }
        
        if case .edit(let workspace) = worksapceDetailState {
            navigationItem.title = workspace.title
        }
        
    }
    
    @objc private func backButtonDidTap(_ sender: UIBarButtonItem) {
        coordinator?.goBackFromWorkspaceCreationScreen()
    }
    
    init(workspacesViewModel: WorkspacesViewModel, worksapceDetailState: WorksapceDetailState) {
        self.workspacesViewModel = workspacesViewModel
        self.worksapceDetailState = worksapceDetailState
        print("AVERAKEDABRA: ALLOC -> WorksapceDetailViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {
        print("AVERAKEDABRA: RELEASE -> WorksapceDetailViewController")
    }

}
