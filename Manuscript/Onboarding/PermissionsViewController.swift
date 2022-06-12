//
//  PermissionsViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class PermissionsViewController: UIViewController {

    weak var coordinator: OnboardingCoordinator? = nil
    private let onboardingViewModel: OnboardingViewModel

    let mainButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Go To Authentication Screen", for: .normal)
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
        onboardingViewModel.onboardingDidFinish()
        coordinator?.startNewFlow(flow: ApplicationFlow.authentication(authenticationFlow: .signIn))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .magenta
        view.addSubview(mainButton)
        mainButton.addTarget(self, action: #selector(mainButtonDidTap), for: .touchUpInside)
    }

    init(onboardingViewModel: OnboardingViewModel) {
        self.onboardingViewModel = onboardingViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {

    }
}
