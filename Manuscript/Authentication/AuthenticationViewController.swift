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
        scrollView.backgroundColor = .cyan
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    let stateSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "Register", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Sign In", at: 0, animated: true)
        segmentedControl.selectedSegmentTintColor = UIColor(named: "accent_blue")
        segmentedControl.selectedSegmentIndex = 0
//        segmentedControl.addTarget(self, action: #selector(segmentedControlIndexDidChange(_:)), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let selectedColor = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let unSelectedColor = [NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.setTitleTextAttributes(unSelectedColor, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedColor, for: .selected)
        return segmentedControl
    }()
    
    let titleTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.preferredFont(for: .largeTitle, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.text = "Create new account"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lottieAnimationView: AnimationView = {
        var animation = AnimationView(animation: Animation.named("105509-delivery-man"))
        animation.play()
        animation.loopMode = .loop
        animation.translatesAutoresizingMaskIntoConstraints = false
        return animation
    }()
    
    let nameTexLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "NAME"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let enterNameTextField: UITextField = {
        var textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = UIColor(named: "gray")
        textField.textColor = UIColor(named: "light_gray")
        textField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let emailTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "EMAIL ADDRESS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let enterEmailTextField: UITextField = {
        var textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = UIColor(named: "gray")
        textField.textColor = UIColor(named: "light_gray")
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "accent_blue")
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.adjustsFontForContentSizeCategory = true
        label.text = "PASSWORD"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let enterPasswordTextField: UITextField = {
        var textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.setLeftPaddingPoints(16)
        textField.backgroundColor = UIColor(named: "gray")
        textField.textColor = UIColor(named: "light_gray")
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray, .font: UIFont.systemFont(ofSize: 14)])
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let forgetPasswordButton: UIButton = {
        let button = UIButton()
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        button.setTitle("Forget password", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.titleLabel?.textAlignment = .left
        button.setTitleColor(Palette.blue, for: .normal)
//        button.addTarget(self, action: #selector(forgetPasswordButtonDidTaped(sender:)), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let primaryButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Palette.blue
        button.layer.cornerRadius = 16
//        button.addTarget(self, action: #selector(primaryButtonDidTaped(sender:)), for: .touchDown)
        button.setTitle("Sign In", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        print("keyboardWillShow")
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        print("keyboardWillHide")

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        view.addSubview(mainScrollView)
        view.addSubview(primaryButton)
        mainScrollView.addSubview(stateSegmentedControl)
        mainScrollView.addSubview(titleTexLabel)
        mainScrollView.addSubview(lottieAnimationView)
        mainScrollView.addSubview(nameTexLabel)
        mainScrollView.addSubview(enterNameTextField)
        mainScrollView.addSubview(emailTextLabel)
        mainScrollView.addSubview(enterEmailTextField)
        mainScrollView.addSubview(passwordTextLabel)
        mainScrollView.addSubview(enterPasswordTextField)
        mainScrollView.addSubview(forgetPasswordButton)


        view.backgroundColor = Palette.lightBlack

        authenticationViewModel.authenticationEventPublisher
                .sink {  [weak self] authenticationEvent in
                    guard let self = self else { return }

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

            /// scrollview
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainScrollView.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -40),
            
            /// stateSegmentedControl
            stateSegmentedControl.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 0),
            stateSegmentedControl.centerXAnchor.constraint(equalTo: mainScrollView.centerXAnchor, constant: 0),
            stateSegmentedControl.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 0),
            stateSegmentedControl.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            stateSegmentedControl.heightAnchor.constraint(equalToConstant: 46),
            
            /// titleTexLabel
            titleTexLabel.topAnchor.constraint(equalTo: stateSegmentedControl.bottomAnchor, constant: 32),
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

extension UIFont {
    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
