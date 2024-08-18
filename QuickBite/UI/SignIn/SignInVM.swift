//
//  SignInVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import Foundation
import RxCocoa
import RxSwift

enum LoginError: Int {
    case accountCheckRequired = 401
    case decodedError
    
    var description: String {
        switch self {
        case .accountCheckRequired:
            return "계정을 확인해 주세요."
        case .decodedError:
            return "로그인 정보를 불러오는데 실패했습니다."
        }
    }
}

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
    }
    
    func transform(input: Input) -> Output {
        
        let isLoginValid = Observable.combineLatest(input.emailText, input.passwordText)
            .map { $0.isEmpty || $1.isEmpty }
            .map { !$0 }
        
        let isLoginValidStatus = isLoginValid
            .asDriver(onErrorJustReturn: false)
        
        let errorMessage = PublishRelay<String>()
        let isLoginSucceeded = PublishRelay<Bool>()
        
        input.signInButtonTapped
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(input.emailText, input.passwordText))
            .map { Userparams.LoginRequest(email: $0, password: $1)}
            .bind(with: self) { owner, param in
                UserAPI.shared.networking(service: .login(param: param), type: Userparams.LoginResponse.self)
                    .subscribe(with: self) { owner, response in
                        switch response {
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
                .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        return Output(isLoginValidStatus: isLoginValidStatus,
                      errorMessage: errorMessage,
                      isLoginSucceeded: isLoginSucceeded)
    }
}
