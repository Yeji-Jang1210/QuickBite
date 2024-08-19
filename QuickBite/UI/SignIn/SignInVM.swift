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
        let signInButtonTapped: ControlEvent<Void>
        let emailText: ControlProperty<String>
        let passwordText: ControlProperty<String>
        let signUpButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let isLoginValidStatus: Driver<Bool>
        let errorMessage: PublishRelay<String>
        let isLoginSucceeded: PublishRelay<Bool>
        let signUpButtonTapped: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let isLoginValid = PublishRelay<Bool>()
        
        let isLoginValidStatus = isLoginValid
            .asDriver(onErrorJustReturn: false)
        
        let errorMessage = PublishRelay<String>()
        let isLoginSucceeded = PublishRelay<Bool>()
        
        input.signInButtonTapped
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(input.emailText, input.passwordText).map { $0.isEmpty || $1.isEmpty })
            .bind {
                isLoginValid.accept(!$0)
            }
            .disposed(by: disposeBag)
        
        isLoginValid
            .filter { $0 }
            .withLatestFrom(Observable.combineLatest(input.emailText, input.passwordText))
            .map { Userparams.LoginRequest(email: $0, password: $1)}
            .flatMap{ param in
                UserAPI.shared.networking(service: .login(param: param), type: Userparams.LoginResponse.self)
            }
            .subscribe(with: self) { owner, networkResult in
                switch networkResult {
                case .success(let result):
                    UserDefaultsManager.shared.token = result.accessToken
                    UserDefaultsManager.shared.refreshToken = result.refreshToken
                    isLoginSucceeded.accept(true)
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
        
        return Output(isLoginValidStatus: isLoginValidStatus,
                      errorMessage: errorMessage,
                      isLoginSucceeded: isLoginSucceeded,
                      signUpButtonTapped: input.signUpButtonTapped)
    }
}
