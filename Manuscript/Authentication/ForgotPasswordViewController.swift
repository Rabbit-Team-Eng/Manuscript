//
//  ForgotPasswordViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    weak var coordinator: AuthenticationCoordinator? = nil
    private let authenticationViewModel: AuthenticationViewModel

    let mainButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Go Back to Authentication Screen", for: .normal)
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
        coordinator?.startNewFlow(flow: ApplicationFlow.onboarding(onboardingFlow: .welcome))
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        view.addSubview(mainButton)
        mainButton.addTarget(self, action: #selector(mainButtonDidTap), for: .touchUpInside)
    }

    init(authenticationViewModel: AuthenticationViewModel) {
        self.authenticationViewModel = authenticationViewModel
        print("AVERAKEDABRA: ALLOC -> ForgotPasswordViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    deinit {
        print("AVERAKEDABRA: RELEASE -> ForgotPasswordViewController")
    }
}
