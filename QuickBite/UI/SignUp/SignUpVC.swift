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
        
        let input = SignUpVM.Input(emailText: emailTextField.text.orEmpty)
        
        let output = viewModel.transform(input: input)
        
        output.emailValidateDescription
            .asDriver(onErrorJustReturn: "")
            .drive(emailTextField.validationStatusText)
            .disposed(by: disposeBag)
        
        output.emailIsValid
            .asDriver(onErrorJustReturn: false)
            .map { $0 ? .systemGreen : .systemRed }
            .drive(emailTextField.validationStatusTextColor)
            .disposed(by: disposeBag)
        
            
//        let user = Userparams.JoinRequest(email: "ggaaammdoo@gmail.com", password: "123456", nick: "ggammmdoo", phoneNum: nil, birthDay: nil)
//        
//        UserAPI.shared.networking(service: .signUp(params: user), type: User.self)
//            .subscribe(with: self) { owner, result in
//                switch result {
//                case .success(let value):
//                    dump(value)
//                case .error(let statusCode):
//                    print("status code: \(statusCode)")
//                case .decodedError:
//                    print("decoded Error")
//                }
//            }
//            .disposed(by: disposeBag)
    }
}
