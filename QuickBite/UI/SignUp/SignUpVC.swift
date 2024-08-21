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

enum UserType {
    case signUp
    case edit
}

final class SignUpVC: BaseVC {
    
    private lazy var scrollView = {
        let object = UIScrollView()
        object.showsHorizontalScrollIndicator = false
        object.addSubview(contentsView)
        return object
    }()
    
    private let contentsView = UIView()
    
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
    
    private lazy var profileInfoStackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 40
        [descriptionLabel, requiredProfileInfoStackView, optionalProfileInfoStackView, signupButton].map { object.addArrangedSubview($0)}
        return object
    }()
    
    private lazy var requiredProfileInfoStackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 20
        [emailStackView, passwordTextField, nicknameTextField].map { object.addArrangedSubview($0)}
        return object
    }()
    
    private lazy var optionalProfileInfoStackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 20
        [optionalLabel, birthdayTextField, phoneNumberTextField].map { object.addArrangedSubview($0)}
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
        object.title = Localized.signup.title
        object.isEnabled = false
        return object
    }()
    
    var viewModel: SignUpVM!
    
    init(title: String = "", isChild: Bool = false, viewModel: SignUpVM) {
        super.init(title: title, isChild: isChild)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentsView)
        
        contentsView.addSubview(descriptionLabel)
        contentsView.addSubview(profileInfoStackView)
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
        
        profileInfoStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalTo(contentsView)
        }
        
        emailValidationButton.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
        
        signupButton.snp.makeConstraints { make in
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
        
        output.emailValidMessage
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
        
        output.passwordValidMessage
            .asDriver(onErrorJustReturn: "")
            .drive(passwordTextField.validationStatusText)
            .disposed(by: disposeBag)
       
        output.passwordIsValid
            .map { $0 ? .systemGreen : .systemRed }
            .asDriver(onErrorJustReturn: .black)
            .drive(passwordTextField.validationStatusTextColor)
            .disposed(by: disposeBag)
        
        output.nicknameIsValid
            .map { $0 ? .systemGreen : .systemRed }
            .asDriver(onErrorJustReturn: .black)
            .drive(nicknameTextField.validationStatusTextColor)
            .disposed(by: disposeBag)
       
        output.nicknameValidMessage
            .asDriver(onErrorJustReturn: "")
            .drive(nicknameTextField.validationStatusText)
            .disposed(by: disposeBag)
        
        output.birthdayIsValid
            .map { $0 ? .systemGreen : .systemRed }
            .asDriver(onErrorJustReturn: .black)
            .drive(birthdayTextField.validationStatusTextColor)
            .disposed(by: disposeBag)
       
        output.birthdayValidMessage
            .asDriver(onErrorJustReturn: "")
            .drive(birthdayTextField.validationStatusText)
            .disposed(by: disposeBag)
        
        output.phoneNumber
            .asDriver(onErrorJustReturn: "")
            .drive(phoneNumberTextField.text)
            .disposed(by: disposeBag)
        
        output.phoneNumberIsValid
            .map { $0 ? .systemGreen : .systemRed }
            .asDriver(onErrorJustReturn: .black)
            .drive(phoneNumberTextField.validationStatusTextColor)
            .disposed(by: disposeBag)
        
        output.phoneNumberValidMessage
            .asDriver(onErrorJustReturn: "")
            .drive(phoneNumberTextField.validationStatusText)
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
    
    func showAlert(title: String, message: String? = nil) -> Single<AlertType> {
        return Single<AlertType>.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let confirm = UIAlertAction(title: "확인", style: .default) { _ in
                single(.success(.ok))
            }
            let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
                single(.success(.cancel))
            }
            
            alert.addAction(confirm)
            alert.addAction(cancel)
            
            present(alert, animated: true)
            return Disposables.create()
        }
    }
}

enum AlertType {
    case ok
    case cancel
}
