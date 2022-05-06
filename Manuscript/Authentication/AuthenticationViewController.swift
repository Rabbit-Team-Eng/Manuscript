//
//  AuthenticationViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit
import Combine

class AuthenticationViewController: UIViewController {

    // TODO: To Be Removed
    let registerButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let signInButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Signed In", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    weak var coordinator: AuthenticationCoordinator? = nil

    private let authenticationViewModel: AuthenticationViewModel
    private var tokens: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(registerButton)
        view.addSubview(signInButton)
        registerButton.addTarget(self, action: #selector(registerButtonNewUserDidTap), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInButtonDidTap), for: .touchUpInside)
        view.backgroundColor = Palette.gray

        authenticationViewModel.authenticationEventPublisher
                .sink {  authenticationEvent in
//                    guard let self = self else { return }

                    if authenticationEvent == .didSignedInSuccessfully {
                        print("EVENT: didSignedInSuccessfully")
                        self.coordinator?.startNewFlow(flow: ApplicationFlow.main(mainFLow: .boards))
                    }

                    if authenticationEvent == .didSignedUpSuccessfully {
                        print("EVENT: didSignedUpSuccessfully")
                        self.coordinator?.startNewFlow(flow: ApplicationFlow.main(mainFLow: .boards))
                    }
                }
                .store(in: &tokens)
    }

    @objc private func registerButtonNewUserDidTap() {
        authenticationViewModel.createNewUser(name: "Tigran", email: "buhaha@test.io", password: "Pass1234!")
    }

    @objc private func signInButtonDidTap() {
        authenticationViewModel.signIn(email: "buhaha@test.io", password: "Pass1234!")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            registerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 64),
            registerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -64),
            registerButton.heightAnchor.constraint(equalToConstant: 30),

            signInButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 16),
            signInButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 64),
            signInButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -64),
            signInButton.heightAnchor.constraint(equalToConstant: 30),

        ])
    }

    init(authenticationViewModel: AuthenticationViewModel) {
        self.authenticationViewModel = authenticationViewModel
        print("AVERAKEDABRA: ALLOC -> AuthenticationViewController")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    deinit {
        print("AVERAKEDABRA: RELEASE -> AuthenticationViewController")
    }
}
