//
//  SignUpVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SignUpVC: BaseVC {
    
    private lazy var scrollView = {
        let object = UIScrollView()
        object.showsHorizontalScrollIndicator = false
        object.addSubview(contentsView)
        return object
    }()
    
    private let contentsView = UIView()
    
    private let titleLabel = {
        let object = UILabel()
        object.font = Font.boldFont(.extraLarge)
        object.text = Localized.title.title
        object.textAlignment = .center
        object.textColor = .white
        return object
    }()
    
    private let descriptionLabel = {
        let object = UILabel()
        object.font = Font.semiBold(.mediumLarge)
        object.text = Localized.signup_description.text
        return object
    }()
    
    private let emailTextField = {
        let object = BaseTextField()
        object.image = ImageAssets.envelope
        object.placeholder = Localized.email_textField_placeholder.text
        return object
    }()
    
    private let emailValidationButton = {
        let object = BaseButton()
        object.isEnabled = false
        object.title = Localized.valid_email_button.title
        object.cornerRadius = 8
        return object
    }()
    
    private lazy var emailStackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.alignment = .center
        object.spacing = 4
        [emailTextField, emailValidationButton].map {object.addArrangedSubview($0)}
        return object
    }()
    
    private let passwordTextField = {
        let object = BaseTextField()
        object.isSecureTextEntry = true
        object.image = ImageAssets.lock
        object.placeholder = Localized.password_textField_placeholder.text
        return object
    }()
    
    private let nicknameTextField = {
        let object = BaseTextField()
        object.image = ImageAssets.person
        object.placeholder = Localized.nickname_textField_placeholder.text
        return object
    }()
    
    private let optionalLabel = {
        let object = UILabel()
        object.text = Localized.signup_optional.text
        object.font = Font.semiBold(.medium)
        return object
    }()
    
    private let birthdayTextField = {
        let object = BaseTextField()
        object.image = ImageAssets.cake
        object.placeholder = Localized.signup_birtday_placeholder.text
        return object
    }()
    
    private let phoneNumberTextField = {
        let object = BaseTextField()
        object.image = ImageAssets.phone
        object.placeholder = Localized.signup_phoneNumber_placeholder.text
        return object
    }()
    
    private let signupButton = {
        let object = BaseButton()
        object.title = Localized.signin_button.title
        object.isEnabled = false
        return object
    }()
    
    let viewModel = SignUpVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentsView)
        
        contentsView.addSubview(titleLabel)
        contentsView.addSubview(descriptionLabel)
        contentsView.addSubview(emailStackView)
        contentsView.addSubview(passwordTextField)
        contentsView.addSubview(nicknameTextField)
        contentsView.addSubview(optionalLabel)
        contentsView.addSubview(birthdayTextField)
        contentsView.addSubview(phoneNumberTextField)
        
        contentsView.addSubview(signupButton)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        scrollView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(20)
            make.centerX.verticalEdges.equalToSuperview()
        }
        
        contentsView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview()
        }
        
        emailStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
        }
        
        emailValidationButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        optionalLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(80)
            make.leading.equalToSuperview()
        }
        
        birthdayTextField.snp.makeConstraints { make in
            make.top.equalTo(optionalLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        phoneNumberTextField.snp.makeConstraints { make in
            make.top.equalTo(birthdayTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
        }
        
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(100)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = SignUpVM.Input(emailText: emailTextField.text.orEmpty,
                                   emailValidateButtonTapped: emailValidationButton.rx.tap,
                                   passwordText: passwordTextField.text.orEmpty,
                                   nicknameText: nicknameTextField.text.orEmpty,
                                   birthdayText: birthdayTextField.text.orEmpty,
                                   phoneNumberText: phoneNumberTextField.text.orEmpty,
                                   signUpButtonTapped: signupButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        let emailStatus = output.emailValidationStatus
            .asDriver(onErrorJustReturn: .isEmpty)
        
        emailStatus
            .map { $0.description }
            .drive(emailTextField.validationStatusText)
            .disposed(by: disposeBag)
        
        emailStatus
            .map { $0 == .valid ? .systemGreen : .systemRed }
            .drive(emailTextField.validationStatusTextColor)
            .disposed(by: disposeBag)
        
        emailStatus
            .map { $0 == .valid ? true : false}
            .drive(emailValidationButton.rx.isEnabled)
            .disposed(by: disposeBag)

        let emailIsValid = output.emailIsValid
            .map{ $0 }
            .asDriver(onErrorJustReturn: false)
        
        output.emailIsValidMessage
            .asDriver(onErrorJustReturn: "")
            .drive(emailTextField.validationStatusText)
            .disposed(by: disposeBag)
        
        emailIsValid
            .map { $0 ? .systemGreen : .systemRed }
            .drive(emailTextField.validationStatusTextColor)
            .disposed(by: disposeBag)
        
        emailIsValid
            .map { $0 ? .lightGray : .black }
            .drive(emailTextField.textColor)
            .disposed(by: disposeBag)
            
        emailIsValid
            .map { !$0 }
            .drive(emailTextField.isEditing, emailValidationButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        let passwordIsValid = output.passwordIsValid
            .asDriver(onErrorJustReturn: false)
        
        passwordIsValid
            .map { $0 ? "" : "5자리 이상 입력해주세요" }
            .drive(passwordTextField.validationStatusText)
            .disposed(by: disposeBag)
       
        passwordIsValid
            .map { $0 ? .systemGreen : .systemRed }
            .drive(passwordTextField.validationStatusTextColor)
            .disposed(by: disposeBag)
        
        let nicknameIsValid = output.nicknameIsValid
            .asDriver(onErrorJustReturn: false)
        
        nicknameIsValid
            .map { $0 ? "" : "3글자 이상으로 입력해주세요" }
            .drive(nicknameTextField.validationStatusText)
            .disposed(by: disposeBag)
       
        nicknameIsValid
            .map { $0 ? .systemGreen : .systemRed }
            .drive(nicknameTextField.validationStatusTextColor)
            .disposed(by: disposeBag)
        
        output.isValidSignUp
            .drive(signupButton.rx.isEnabled)
            .disposed(by: disposeBag)
            
        output.errorMessage
            .asDriver(onErrorJustReturn: "")
            .drive(with: self) { owner, msg in
                owner.showToastMsg(msg: msg)
            }
            .disposed(by: disposeBag)
        
        output.isLoginSuccess
            .asDriver(onErrorJustReturn: false)
            .filter { $0 }
            .drive(with: self){ owner, _ in
                owner.changeRootViewController(MainTBC(), animated: true)
            }
            .disposed(by: disposeBag)
    }
}
