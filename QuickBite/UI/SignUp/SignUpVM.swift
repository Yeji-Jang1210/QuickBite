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
    }
    
    struct Output {
        let emailValidateDescription: PublishRelay<String>
        let emailIsValid: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let emailValidateDescription = PublishRelay<String>()
        let emailIsValid = PublishRelay<Bool>()
        
        input.emailText
            .map { EmailValidationState.validateEmail($0) }
            .bind {
                emailValidateDescription.accept($0.description)
                emailIsValid.accept($0 == .valid)
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(emailValidateDescription: emailValidateDescription,
                      emailIsValid: emailIsValid)
    }
}
