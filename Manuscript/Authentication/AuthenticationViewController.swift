//
//  AuthenticationViewController.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import UIKit
import Combine
import Lottie

class AuthenticationViewController: UIViewController {
    
    weak var coordinator: AuthenticationCoordinator? = nil
    
    private let authenticationViewModel: AuthenticationViewModel
    private var tokens: Set<AnyCancellable> = []
    
    private let mainScrollView: UIScrollView  = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let stateSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "Register", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Sign In", at: 0, animated: true)
        segmentedControl.selectedSegmentTintColor = UIColor(named: "accent_blue")
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let selectedColor = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let unSelectedColor = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(unSelectedColor, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedColor, for: .selected)
        return segmentedControl
    }()
    
    private let titleTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .largeTitle, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.text = "Welcome back!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lottieAnimationView: AnimationView = {
        var animation = AnimationView(animation: Animation.named("107115-id-authentication"))
        animation.play()
        animation.loopMode = .loop
        animation.translatesAutoresizingMaskIntoConstraints = false
        return animation
    }()
    
    private let nameTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "NAME"
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let enterNameTextField: UITextField = {
        var textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.isHidden = true
        textField.backgroundColor = Palette.gray
        textField.textColor = Palette.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "EMAIL ADDRESS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let enterEmailTextField: UITextField = {
        var textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = Palette.gray
        textField.textColor = Palette.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    private let passwordTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "PASSWORD"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let enterPasswordTextField: UITextField = {
        var textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = Palette.gray
        textField.textColor = Palette.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let forgetPasswordButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.setTitle("Forget password", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.titleLabel?.textAlignment = .left
        button.setTitleColor(Palette.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let primaryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Palette.blue
        button.layer.cornerRadius = 16
        button.setTitle("Sign In", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.style = .large
        activityIndicatorView.color = .white
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func segmentedControlIndexDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            titleTexLabel.text = "Welcome back!"
            primaryButton.setTitle("Sign In", for: .normal)
            nameTexLabel.isHidden = true
            enterNameTextField.isHidden = true
            forgetPasswordButton.isHidden = false
        }
        
        if sender.selectedSegmentIndex == 1 {
            titleTexLabel.text = "Create new account"
            primaryButton.setTitle("Register", for: .normal)
            nameTexLabel.isHidden = false
            enterNameTextField.isHidden = false
            forgetPasswordButton.isHidden = true
        }
        
        resetTextFieldPlaceholders()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        view.addSubview(mainScrollView)
        view.addSubview(primaryButton)
        view.addSubview(stateSegmentedControl)
        view.addSubview(activityIndicator)
        mainScrollView.addSubview(titleTexLabel)
        mainScrollView.addSubview(lottieAnimationView)
        mainScrollView.addSubview(nameTexLabel)
        mainScrollView.addSubview(enterNameTextField)
        mainScrollView.addSubview(emailTextLabel)
        mainScrollView.addSubview(enterEmailTextField)
        mainScrollView.addSubview(passwordTextLabel)
        mainScrollView.addSubview(enterPasswordTextField)
        mainScrollView.addSubview(forgetPasswordButton)
        
        stateSegmentedControl.addTarget(self, action: #selector(segmentedControlIndexDidChange(_:)), for: .valueChanged)
        primaryButton.addTarget(self, action: #selector(primaryButtonDidTap(_:)), for: .touchUpInside)
        forgetPasswordButton.addTarget(self, action: #selector(forgetPasswordButtonDidTap(_:)), for: .touchUpInside)
        
        
        view.backgroundColor = Palette.lightBlack
        
        authenticationViewModel.authenticationEventPublisher.sink { completion in } receiveValue: {  [weak self] authenticationEvent in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if authenticationEvent == .wrongFormarForBothEmailAndPassword {
                let message = AuthenticationEvent.wrongFormarForBothEmailAndPassword.rawValue
                self.enterEmailTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
                self.enterPasswordTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
            }
            
            if authenticationEvent == .didSignedInSuccessfully {
                self.coordinator?.startNewFlow(flow: ApplicationFlow.main(mainFLow: .boards))
            }
            
            if authenticationEvent == .didSignedUpSuccessfully {
                self.coordinator?.startNewFlow(flow: ApplicationFlow.main(mainFLow: .boards))
            }
        }
        .store(in: &tokens)
        
        
    }
    
    @objc private func forgetPasswordButtonDidTap(_ sender: UIButton) {
        sender.showAnimation { [weak self] in
            guard let self = self else { return }
            self.coordinator?.navigateToForgotPasswordScreen()
        }
    }
    
    @objc private func primaryButtonDidTap(_ sender: UIButton) {
        
        sender.showAnimation { [weak self] in
            guard let self = self,
                  let name = self.enterNameTextField.text,
                  let email = self.enterEmailTextField.text,
                  let password = self.enterPasswordTextField.text
            else { return }
            
            self.activityIndicator.startAnimating()
            
            if self.stateSegmentedControl.selectedSegmentIndex == 0 {
                self.authenticationViewModel.signIn(email: email, password: password)
            }
            
            if self.stateSegmentedControl.selectedSegmentIndex == 1 {
                self.authenticationViewModel.createNewUser(name: name, email: email, password: password)
            }
        }
    }

    
    private func resetTextFieldPlaceholders() {
        enterNameTextField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
        enterNameTextField.text = ""
        enterEmailTextField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
        enterEmailTextField.text = ""
        enterPasswordTextField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
        enterPasswordTextField.text = ""
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint.activate([
            
            /// activityIndicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 100),
            activityIndicator.widthAnchor.constraint(equalToConstant: 100),
            
            /// stateSegmentedControl
            stateSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stateSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            stateSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stateSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stateSegmentedControl.heightAnchor.constraint(equalToConstant: 46),
            
            
            /// scrollview
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainScrollView.topAnchor.constraint(equalTo: stateSegmentedControl.bottomAnchor, constant: 20),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainScrollView.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -40),
            
            /// titleTexLabel
            titleTexLabel.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 32),
            titleTexLabel.centerXAnchor.constraint(equalTo: mainScrollView.centerXAnchor, constant: 0),
            titleTexLabel.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 0),
            titleTexLabel.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            titleTexLabel.heightAnchor.constraint(equalToConstant: 38),
            
            /// lottieAnimationView
            lottieAnimationView.topAnchor.constraint(equalTo: titleTexLabel.bottomAnchor, constant: 27),
            lottieAnimationView.centerXAnchor.constraint(equalTo: mainScrollView.centerXAnchor, constant: 0),
            lottieAnimationView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 0),
            lottieAnimationView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            lottieAnimationView.heightAnchor.constraint(equalToConstant: 119),
            
            /// nameTexLabel
            nameTexLabel.topAnchor.constraint(equalTo: lottieAnimationView.bottomAnchor, constant: 27),
            nameTexLabel.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 16),
            nameTexLabel.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            nameTexLabel.heightAnchor.constraint(equalToConstant: 15),
            
            /// enterNameTextField
            enterNameTextField.topAnchor.constraint(equalTo: nameTexLabel.bottomAnchor, constant: 8),
            enterNameTextField.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 0),
            enterNameTextField.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            enterNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            /// nameTexLabel
            emailTextLabel.topAnchor.constraint(equalTo: enterNameTextField.bottomAnchor, constant: 27),
            emailTextLabel.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 16),
            emailTextLabel.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            emailTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            /// enterNameTextField
            enterEmailTextField.topAnchor.constraint(equalTo: emailTextLabel.bottomAnchor, constant: 8),
            enterEmailTextField.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 0),
            enterEmailTextField.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            enterEmailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            /// passwordTextLabel
            passwordTextLabel.topAnchor.constraint(equalTo: enterEmailTextField.bottomAnchor, constant: 27),
            passwordTextLabel.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 16),
            passwordTextLabel.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            passwordTextLabel.heightAnchor.constraint(equalToConstant: 15),
            
            /// enterPasswordTextField
            enterPasswordTextField.topAnchor.constraint(equalTo: passwordTextLabel.bottomAnchor, constant: 8),
            enterPasswordTextField.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 0),
            enterPasswordTextField.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            enterPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            /// forgetPasswordButton
            forgetPasswordButton.topAnchor.constraint(equalTo: enterPasswordTextField.bottomAnchor, constant: 8),
            forgetPasswordButton.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 16),
            forgetPasswordButton.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            forgetPasswordButton.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 0),
            forgetPasswordButton.heightAnchor.constraint(equalToConstant: 18),
            
            /// primaryButton
            primaryButton.centerXAnchor.constraint(equalTo: mainScrollView.centerXAnchor, constant: 0),
            primaryButton.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 0),
            primaryButton.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            primaryButton.heightAnchor.constraint(equalToConstant: 55),
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
