//
//  SignUpVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpVM: BaseVM, BaseVMProvider {
    
    struct Input {
        let emailText: ControlProperty<String>
        let emailValidateButtonTapped: ControlEvent<Void>
        let passwordText: ControlProperty<String>
        let nicknameText: ControlProperty<String>
        let birthdayText: ControlProperty<String>
        let phoneNumberText: ControlProperty<String>
        let signUpButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let emailValidationStatus: PublishRelay<ValidationEmail>
        let emailIsValid: PublishRelay<Bool>
        let emailValidMessage: PublishRelay<String>
        
        let passwordIsValid: PublishRelay<Bool>
        let passwordValidMessage: PublishRelay<String>
        
        let nicknameIsValid: PublishRelay<Bool>
        let nicknameValidMessage: PublishRelay<String>
        
        let birthdayIsValid: PublishRelay<Bool>
        let birthdayValidMessage: PublishRelay<String>
        
        let phoneNumber: PublishRelay<String>
        let phoneNumberIsValid: PublishRelay<Bool>
        let phoneNumberValidMessage: PublishRelay<String>
        
        let isValidSignUp: Driver<Bool>
        let isLoginSuccess: PublishRelay<Bool>
        let errorMessage: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        
        let emailValidationStatus = PublishRelay<ValidationEmail>()
        let emailIsValid = PublishRelay<Bool>()
        let emailValidMessage = PublishRelay<String>()
        
        let passwordIsValid = PublishRelay<Bool>()
        let passwordValidMessage = PublishRelay<String>()
        
        let nicknameIsValid = PublishRelay<Bool>()
        let nicknameValidMessage = PublishRelay<String>()
        
        let birthdayIsValid = PublishRelay<Bool>()
        let birthdayValidMessage = PublishRelay<String>()
        
        let phoneNumber = PublishRelay<String>()
        let phoneNumberValidMessage = PublishRelay<String>()
        let phoneNumberIsValid = PublishRelay<Bool>()
        
        let isLoginSuccess = PublishRelay<Bool>()
        let errorMessage = PublishRelay<String>()
        
        input.emailText
            .distinctUntilChanged()
            .map { ValidationEmail.validateEmail($0) }
            .bind { emailValidationStatus.accept($0) }
            .disposed(by: disposeBag)
        
        input.emailValidateButtonTapped
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(input.emailText)
            .map{ Userparams.ValidationEmailRequest(email: $0) }
            .flatMap { param in
                UserAPI.shared.networking(service: .validationEmail(param: param), type: Userparams.StatusMessageResponse.self)
            }
            .subscribe(with: self){ owner, networkResult in
                switch networkResult {
                case .success(let result):
                    emailValidMessage.accept(result.message)
                    emailIsValid.accept(true)
                case .error(let statusCode):
                    guard let error = ValidationEmailError(rawValue: statusCode) else {
                        emailIsValid.accept(false)
                        errorMessage.accept("알수없는 오류")
                        return
                    }
                    emailIsValid.accept(false)
                    emailValidMessage.accept(error.message)
                }
            }
            .disposed(by: disposeBag)
        
        input.passwordText
            .throttle(.microseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { $0.count > 4 }
            .bind { result in
                if result {
                    passwordValidMessage.accept("")
                } else {
                    passwordValidMessage.accept("5자리 이상 입력해주세요")
                }
                
                passwordIsValid.accept(result)
            }
            .disposed(by: disposeBag)
            
        input.nicknameText
            .throttle(.microseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { !$0.contains(" ") && $0.count > 2 }
            .bind { result in
                if result {
                    nicknameValidMessage.accept("")
                } else {
                    nicknameValidMessage.accept("공백을 제거한 세자리 이상 문자를 입력해주세요")
                }
                
                nicknameIsValid.accept(result)
            }
            .disposed(by: disposeBag)
            
        //전화번호, 생년월일 구현 필요
        input.phoneNumberText
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, text in
                ValidationPhoneNumber.validatePhoneNumber(text) { result in
                    phoneNumberIsValid.accept(result.isValid)
                    phoneNumberValidMessage.accept(result.message)
                    
                    if result == .isNumber {
                        phoneNumber.accept(ValidationPhoneNumber.format(phoneNumber: text))
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.birthdayText
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, text in
                ValidationBirthday.validateBirthday(text) { result in
                    birthdayValidMessage.accept(result.message)
                    birthdayIsValid.accept(result.isValid)
                }
            }
            .disposed(by: disposeBag)
        
        let isValidSignup = Observable.combineLatest(emailIsValid, passwordIsValid, nicknameIsValid)
            .map{ $0 && $1 && $2 }
            .filter { $0 }
            .asDriver(onErrorJustReturn: false)
        
        input.signUpButtonTapped
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .flatMapLatest { _ in
            Observable.zip(input.emailText,
                                                   input.passwordText,
                                                   input.nicknameText,
                                                   input.phoneNumberText,
                                                   input.birthdayText)
               .compactMap { email, password, nick, phoneNum, birthDay -> Userparams.JoinRequest in
                   let user = Userparams.JoinRequest(email: email, password: password, nick: nick, phoneNum: phoneNum, birthDay: birthDay)
                   return user
               }
        }
        .flatMapLatest { param in
            UserAPI.shared.networking(service: .signUp(param: param), type: Userparams.SignupResponse.self)
        }
        .withLatestFrom(input.passwordText){ (networkResult, pwd) in
            switch networkResult {
            case .success(let result):
                return Userparams.LoginRequest(email: result.email, password: pwd)
            case .error(let statusCode):
                if let error = SignUpError(rawValue: statusCode) {
                    errorMessage.accept(error.message)
                }
            }
            
            return nil
        }
        .compactMap { $0 }
        .flatMapLatest{ param in
            UserAPI.shared.networking(service: .login(param: param), type: Userparams.LoginResponse.self)
        }
        .subscribe(with: self){ owner, networkResult in
            switch networkResult {
            case .success(let result):
                UserDefaultsManager.shared.setUserDetauls(result)
                isLoginSuccess.accept(true)
            case .error(let statusCode):
                guard let error = SignInError(rawValue: statusCode) else { errorMessage.accept("알수없는 오류")
                    return
                }
                errorMessage.accept(error.message)
            }
        }
        .disposed(by: disposeBag)
        
        
        
        return Output(emailValidationStatus: emailValidationStatus,
                      emailIsValid:emailIsValid,
                      emailValidMessage: emailValidMessage,
                      passwordIsValid: passwordIsValid,
                      passwordValidMessage: passwordValidMessage,
                      nicknameIsValid: nicknameIsValid,
                      nicknameValidMessage: nicknameValidMessage,
                      birthdayIsValid: birthdayIsValid,
                      birthdayValidMessage: birthdayValidMessage,
                      phoneNumber: phoneNumber,
                      phoneNumberIsValid: phoneNumberIsValid,
                      phoneNumberValidMessage: phoneNumberValidMessage,
                      isValidSignUp: isValidSignup,
                      isLoginSuccess: isLoginSuccess,
                      errorMessage: errorMessage)
    }
}
