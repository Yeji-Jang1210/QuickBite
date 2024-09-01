//
//  SignInVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignInVC: BaseVC {
    
    private let titleImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.image = ImageAssets.titleImage
        return object
    }()
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 12
        [titleLabel, subtitleLabel].map {object.addArrangedSubview($0)}
        return object
    }()
    
    private let titleLabel = {
        let object = UILabel()
        object.font = Font.boldFont(.extraLarge)
        object.text = Localized.title.title
        object.textAlignment = .center
        object.textColor = Color.primaryColor
        return object
    }()
    
    private let subtitleLabel = {
        let object = UILabel()
        object.font = Font.boldFont(.smallLarge)
        object.text = Localized.subtitle.title
        object.textAlignment = .center
        object.textColor = .darkGray
        return object
    }()
    
    private let emailTextField = {
        let object = BaseTextField()
        object.image = ImageAssets.person
        object.placeholder = Localized.email_textField_placeholder.text
        return object
    }()
    
    private let passwordTextField = {
        let object = BaseTextField()
        object.image = ImageAssets.lock
        object.isSecureTextEntry = true
        object.placeholder = Localized.password_textField_placeholder.text
        return object
    }()
    
    private let signinButton = {
        let object = BaseButton()
        object.title = Localized.signin_button.title
        return object
    }()
    
    private let signupButton = {
       let object = UIButton()
        object.setAttributedTitle(NSAttributedString(string: Localized.signup.title, attributes: [.font: Font.semiBold(.medium), .foregroundColor: Color.primaryColor]), for: .normal)
        return object
    }()
    
    private let viewModel = SignInVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(titleImageView)
        view.addSubview(stackView)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signinButton)
        view.addSubview(signupButton)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.bottom.equalTo(stackView.snp.top).offset(-40)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
            make.bottom.equalTo(view.snp.centerY).offset(-40)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(40)
            make.top.equalTo(view.snp.centerY).offset(40)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(40)
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
        }
        
        signinButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(40)
            make.height.equalTo(44)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
        }
        
        signupButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = SignInVM.Input(signInButtonTapped: signinButton.rx.tap,
                                   emailText: emailTextField.text.orEmpty,
                                   passwordText: passwordTextField.text.orEmpty,
                                   signUpButtonTapped: signupButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.isLoginValidStatus
            .filter { !$0 }
            .drive(with: self) { owner, _ in
                owner.showToastMsg(msg: Localized.login_invalid.text)
            }
            .disposed(by: disposeBag)
        
        output.errorMessage
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, msg in
                owner.showToastMsg(msg: msg)
            }
            .disposed(by: disposeBag)
        
        output.isLoginSucceeded
            .asDriver(onErrorJustReturn: false)
            .drive(with: self){ owner, result in
                owner.changeRootViewController(MainTBC(), animated: true)
            }
            .disposed(by: disposeBag)
        
        output.signUpButtonTapped
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(SignUpVC(title: Localized.signup.title, isChild: true), animated: true)
            }
            .disposed(by: disposeBag)
        
        
    }
}
