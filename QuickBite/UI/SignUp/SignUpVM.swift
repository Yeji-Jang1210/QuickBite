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
    }
    
    struct Output {
        let emailValidationStatus: BehaviorRelay<EmailValidationState>
        let emailIsValid: PublishRelay<(Bool,String)>
    }
    
    func transform(input: Input) -> Output {
        
        let emailValidationStatus = BehaviorRelay<EmailValidationState>(value: .isEmpty)
        let emailIsValid = PublishRelay<(Bool,String)>()
        
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
                    emailIsValid.accept((true, result.message))
                case .error(let statusCode):
                    guard let error = ValidationError(rawValue: statusCode) else {
                        emailIsValid.accept((false, "알수없는 오류"))
                        return
                    }
                case .decodedError:
                    emailIsValid.accept((false, "알수없는 오류"))
                }
            }
            .disposed(by: disposeBag)
            
        
        return Output(emailValidationStatus: emailValidationStatus,
                      emailIsValid:emailIsValid)
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
