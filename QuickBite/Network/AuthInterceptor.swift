//
//  AuthInterceptor.swift
//  QuickBite
//
//  Created by 장예지 on 8/28/24.
//

import Foundation
import RxSwift
import Alamofire
import Kingfisher

final class AuthInterceptor: RequestInterceptor {
    static let shared = AuthInterceptor()
    
    private init(){}
    private let disposeBag = DisposeBag()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix(APIInfo.baseURL) == true else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.headers.add(name:Header.authorization.rawValue, value: UserDefaultsManager.shared.token)
        urlRequest.headers.add(name:Header.refresh.rawValue, value: UserDefaultsManager.shared.refreshToken)
        print("adator 적용 \(urlRequest.headers)")
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        print(">>>>>retry 진입")
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 419 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        let param = Userparams.TokenRequest()
        
        UserAPI.shared.networking(service: .refreshToken(param: param), type: Userparams.TokenResponse.self)
            .debug("토큰 갱신")
            .subscribe(with: self) { owner, networkResult in
                switch networkResult {
                case .success(let result):
                    
                    KingfisherManager.shared.defaultOptions = [.requestModifier(TokenPlugin(token: result.accessToken))]
                    UserDefaultsManager.shared.token = result.accessToken
                    print("😊AccessToken: \(UserDefaultsManager.shared.token)")
                    completion(.retryWithDelay(1))
                case .error(_):
                    //로그읺 화면 띄우기
                    //NotificationCenter.default.post(name: "refreshTokenExpired", object: nil, userInfo: ["showLoginModel": true]) 이런식으로..
                    completion(.doNotRetry)
                }
            }
            .disposed(by: disposeBag)
        
    }
}
