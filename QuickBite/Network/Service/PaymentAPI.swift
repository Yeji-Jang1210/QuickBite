//
//  PaymentAPI.swift
//  QuickBite
//
//  Created by 장예지 on 9/1/24.
//

import Foundation
import Moya
import RxSwift

enum PaymentService {
    case validation(param: PaymentParams.ValidationRequest)
}

extension PaymentService: TargetType {
    
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return APIService.shared.baseURL
    }
    
    var path: String {
        switch self {
        case .validation:
            return "/v1/payments/validation"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .validation(let param):
            return .requestJSONEncodable(param)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .validation:
            return [
                Header.authorization.rawValue: UserDefaultsManager.shared.token,
                Header.sesacKey.rawValue: APIInfo.key
            ]
        }
    }
}

class PaymentAPI {
    private init(){}
    static let shared = PaymentAPI()
    
    let provider = MoyaProvider<PaymentService>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    func networking<T: Codable>(service: PaymentService, type: T.Type) -> Single<NetworkResult<T>> {
        return Single<NetworkResult<T>>.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            provider.request(service) { result in
                switch result {
                case .success(let response):
                    switch response.statusCode {
                    case 200..<300:
                        guard let data = try? response.map(T.self) else {
                            return
                        }
                        single(.success(.success(data)))
                    default:
                        single(.success(.error(response.statusCode)))
                    }
                case .failure(let error):
                    single(.success(.error(error.errorCode)))
                }
            }
            
            return Disposables.create()
        }
    }
}
