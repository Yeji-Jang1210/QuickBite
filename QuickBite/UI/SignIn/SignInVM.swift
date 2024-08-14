//
//  SignInVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import Foundation
import RxCocoa
import RxSwift

final class SignInVM: BaseVM, BaseVMProtocol {
    
    struct Input {
        let signUpButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let signUpBUttonTapped: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        return Output(signUpBUttonTapped: input.signUpButtonTapped)
    }
}
