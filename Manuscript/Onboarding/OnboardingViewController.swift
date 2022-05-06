//
//  OnboardingViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit

class OnboardingViewController: UIViewController {

    weak var coordinator: OnboardingCoordinator? = nil

    let mainButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Navigate To Permissions", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let onboardingViewModel: OnboardingViewModel

    init(onboardingViewModel: OnboardingViewModel) {
        self.onboardingViewModel = onboardingViewModel
        print("AVERAKEDABRA: ALLOC -> OnboardingViewController")
        super.init(nibName: nil, bundle: nil)
    }

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
        coordinator?.navigateToPermissionsScreen()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        view.addSubview(mainButton)
        mainButton.addTarget(self, action: #selector(mainButtonDidTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    deinit {
        print("AVERAKEDABRA: RELEASE -> OnboardingViewController")
    }
}
