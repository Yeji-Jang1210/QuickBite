//
//  UserAPI.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import Foundation
import Moya
import RxSwift

enum UserService {
    case login(param: Userparams.LoginRequest)
    case signUp(param: Userparams.JoinRequest)
    case validationEmail(param: Userparams.ValidationEmailRequest)
    case refreshToken(param: Userparams.TokenRequest)
    case withdraw
}

extension UserService: TargetType {
    var baseURL: URL {
        return APIService.shared.baseURL
    }
    
    var path: String {
        switch self {
        case .login:
            return "/v1/users/login"
        case .signUp:
            return "/v1/users/join"
        case .validationEmail:
            return "/v1/validation/email"
        case .refreshToken:
            return "/v1/auth/refresh"
        case .withdraw:
            return "v1/users/withdraw"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .signUp, .validationEmail:
            return .post
        case .refreshToken, .withdraw:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .login(let param):
            return .requestJSONEncodable(param)
        case .signUp(let param):
            return .requestJSONEncodable(param)
        case .validationEmail(let param):
            return .requestJSONEncodable(param)
        case .refreshToken:
            return .requestPlain
        case .withdraw:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signUp, .validationEmail, .login:
            return APIService.shared.header
        case .refreshToken(let param):
            return [
                Header.authorization.rawValue: param.token,
                Header.sesacKey.rawValue: APIInfo.key,
                Header.refresh.rawValue: param.refreshToken
            ]
        case .withdraw:
            return [
                Header.authorization.rawValue: UserDefaultsManager.shared.token,
                Header.sesacKey.rawValue: APIInfo.key
            ]
        }
    }
}

enum NetworkResult<T> {
    case success(T)
    case error(Int)
    case decodedError
}

class UserAPI {
    private init(){}
    static let shared = UserAPI()
    
    let provider = MoyaProvider<UserService>(plugins: [MoyaLoggingPlugin()])
    
    func networking<T: Codable>(service: UserService, type: T.Type) -> Single<NetworkResult<T>> {
        return Single<NetworkResult<T>>.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            provider.request(service) { result in
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case 200..<300:
                        guard let data = try? response.map(T.self) else {
                            single(.success(.decodedError))
                            return
                        }
                        single(.success(.success(data)))
                    default:
                        single(.success(.error(response.statusCode)))
                    }
                case .failure(let error):
                    return print("error - \(error)")
                }
            }
            
            return Disposables.create()
        }
    }
}
