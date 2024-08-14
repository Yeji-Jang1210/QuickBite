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
    
    private let passwordTextField = {
        let object = BaseTextField()
        object.isSecureTextEntry = true
        object.image = ImageAssets.lock
        object.placeholder = Localized.email_textField_placeholder.text
        return object
    }()
    
    private let nicknameTextField = {
        let object = BaseTextField()
        object.image = ImageAssets.person
        object.placeholder = Localized.email_textField_placeholder.text
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
        object.backgroundColor = Color.primaryColor
        object.titleLabel?.font = Font.regular(.medium)
        object.setTitle(Localized.signin_button.title, for: .normal)
        object.isEnabled = false
        return object
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentsView)
        
        contentsView.addSubview(titleLabel)
        contentsView.addSubview(descriptionLabel)
        contentsView.addSubview(emailTextField)
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
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview()
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
}
