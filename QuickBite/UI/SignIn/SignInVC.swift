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
    
    let titleImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.image = ImageAssets.titleImage
        return object
    }()
    
    let titleLabel = {
        let object = UILabel()
        object.font = Font.boldFont(.extraLarge)
        object.text = Localized.title.title
        object.textAlignment = .center
        object.textColor = .white
        return object
    }()
    
    let signinView = {
        let object = UIView()
        object.backgroundColor = .white
        object.clipsToBounds = true
        object.layer.cornerRadius = 24
        return object
    }()
    
    let emailTextField = {
        let object = BaseTextField()
        object.image = ImageAssets.person
        object.placeholder = Localized.email_textField_placeholder.text
        return object
    }()
    
    let passwordTextField = {
        let object = BaseTextField()
        object.image = ImageAssets.lock
        object.isSecureTextEntry = true
        object.placeholder = Localized.password_textField_placeholder.text
        return object
    }()
    
    let signinButton = {
        let object = BaseButton()
        object.backgroundColor = Color.primaryColor
        object.titleLabel?.font = Font.regular(.medium)
        object.setTitle(Localized.signin_button.title, for: .normal)
        return object
    }()
    
    let signupButton = {
       let object = UIButton()
        object.setAttributedTitle(NSAttributedString(string: Localized.signup.title, attributes: [.font: Font.semiBold(.medium), .foregroundColor: Color.primaryColor]), for: .normal)
        return object
    }()
    
    let viewModel = SignInVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.primaryColor
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        view.addSubview(titleImageView)
        view.addSubview(titleLabel)
        view.addSubview(signinView)
        
        signinView.addSubview(emailTextField)
        signinView.addSubview(passwordTextField)
        signinView.addSubview(signinButton)
        signinView.addSubview(signupButton)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(signinView.snp.top).offset(-40)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.bottom.equalTo(titleLabel.snp.top).offset(-40)
        }
        
        signinView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(UIScreen.main.bounds.height / 2)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(100)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
        }
        
        signinButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
        }
        
        signupButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    override func bind() {
        super.bind()
        
        let input = SignInVM.Input(signUpButtonTapped: signupButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.signUpBUttonTapped
            .asDriver()
            .drive(with: self){ owner, _ in
                owner.navigationController?.pushViewController(SignUpVC(title: Localized.signup.title, isChild: true), animated: true)
            }
            .disposed(by: disposeBag)
    }
}
