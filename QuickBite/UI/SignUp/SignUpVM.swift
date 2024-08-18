//
//  SignUpVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpVM: BaseVM, BaseVMProtocol {
    
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
        let emailValidationStatus: BehaviorRelay<EmailValidationState>
        let emailIsValid: PublishRelay<Bool>
        let emailIsValidMessage: PublishRelay<String>
        let passwordIsValid: Observable<Bool>
        let nicknameIsValid: Observable<Bool>
        let isValidSignUp: Driver<Bool>
        let isLoginSuccess: PublishRelay<Bool>
        let errorMessage: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        
        let emailValidationStatus = BehaviorRelay<EmailValidationState>(value: .isEmpty)
        let emailIsValid = PublishRelay<Bool>()
        let emailIsValidMessage = PublishRelay<String>()
        let isLoginInfo = PublishRelay<Userparams.LoginRequest>()
        let isLoginSuccess = PublishRelay<Bool>()
        let errorMessage = PublishRelay<String>()
        
        input.emailText
            .distinctUntilChanged()
            .map { EmailValidationState.validateEmail($0) }
            .bind {
                emailValidationStatus.accept($0)
            }
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
                    emailIsValidMessage.accept(result.message)
                    emailIsValid.accept(true)
                case .error(let statusCode):
                    guard ValidationError(rawValue: statusCode) != nil else {
                        emailIsValid.accept(false)
                        errorMessage.accept("알수없는 오류")
                        return
                    }
                case .decodedError:
                    emailIsValid.accept(false)
                    errorMessage.accept("알수없는 오류")
                }
            }
            .disposed(by: disposeBag)
        
        let passwordIsValid = input.passwordText
            .distinctUntilChanged()
            .map { $0.count > 5 }
        
        
        let nicknameIsValid = input.nicknameText
            .distinctUntilChanged()
            .map { $0.count > 5 }
            
        //전화번호, 생년월일 구현 필요
        
        
        let isValidSignup = Observable.combineLatest(emailIsValid, passwordIsValid, nicknameIsValid)
            .map{ $0 && $1 && $2 }
            .filter { $0 }
            .asDriver(onErrorJustReturn: false)
        
        input.signUpButtonTapped
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .flatMap { _ in
            Observable.combineLatest(input.emailText,
                                                   input.passwordText,
                                                   input.nicknameText,
                                                   input.phoneNumberText,
                                                   input.birthdayText)
               .compactMap { email, password, nick, phoneNum, birthDay -> Userparams.JoinRequest in
                   let user = Userparams.JoinRequest(email: email, password: password, nick: nick, phoneNum: phoneNum, birthDay: birthDay)
                   return user
               }
        }
        .flatMap { param in
            UserAPI.shared.networking(service: .signUp(param: param), type: Userparams.SignupResponse.self)
        }
        .subscribe(with: self) { owner, networkResult in
            switch networkResult {
            case .success(let result):
                input.passwordText.subscribe { pwd in
                    let param = Userparams.LoginRequest(email: result.email, password: pwd)
                    isLoginInfo.accept(param)
                }
                .disposed(by: owner.disposeBag)
                
            case .error(let statusCode):
                guard let error = SignUpError(rawValue: statusCode) else {
                    errorMessage.accept(SignUpError.unknownError.message)
                    return
                }
                errorMessage.accept(error.message)
            case .decodedError:
                errorMessage.accept("알수없는 오류")
            }
        }
        .disposed(by: disposeBag)
        
        isLoginInfo
            .flatMap{ param in
                UserAPI.shared.networking(service: .login(param: param), type: Userparams.LoginResponse.self)
            }
            .subscribe(with: self) { owner, networkResult in
                switch networkResult {
                case .success(let result):
                    UserDefaultsManager.shared.token = result.accessToken
                    UserDefaultsManager.shared.refreshToken = result.refreshToken
                    isLoginSuccess.accept(true)
                case .error(let statusCode):
                    guard let error = LoginError(rawValue: statusCode) else { errorMessage.accept("알수없는 오류")
                        return
                    }
                    errorMessage.accept(error.description)
                case .decodedError:
                    errorMessage.accept(LoginError.decodedError.description)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(emailValidationStatus: emailValidationStatus,
                      emailIsValid:emailIsValid,
                      emailIsValidMessage: emailIsValidMessage,
                      passwordIsValid: passwordIsValid,
                      nicknameIsValid: nicknameIsValid,
                      isValidSignUp: isValidSignup,
                      isLoginSuccess: isLoginSuccess,
                      errorMessage: errorMessage)
    }
}

enum ValidationError: Int {
    case missingRequiredField = 400
    case invalidEmailAddress = 409
    
    // 에러 상태에 따라 적절한 메시지를 제공
    var message: String {
        switch self {
        case .missingRequiredField:
            return "필수값을 채워주세요."
        case .invalidEmailAddress:
            return "사용이 불가능한 이메일입니다."
        }
    }
}
 
enum SignUpError: Int {
    case registeredUser = 409
    case unknownError
    case missingRequiredField = 400
    
    var message: String {
        switch self {
        case .missingRequiredField:
            return "필수값을 채워주세요."
        case .registeredUser:
            return "이미 등록된 회원입니다."
        case .unknownError:
            return "알수없는 오류입니다."
        }
    }
}
