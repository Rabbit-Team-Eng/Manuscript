//
//  WorksapceCreateViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 6/8/22.
//

import UIKit

class WorksapceCreateViewController: UIViewController {
    
    private let workspacesViewModel: WorkspacesViewModel

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Palette.gray
    }
    
    init(workspacesViewModel: WorkspacesViewModel) {
        self.workspacesViewModel = workspacesViewModel
        print("AVERAKEDABRA: ALLOC -> WorksapceCreateViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {
        print("AVERAKEDABRA: RELEASE -> WorksapceCreateViewController")
    }

}
