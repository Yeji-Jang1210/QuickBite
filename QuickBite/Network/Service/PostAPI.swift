//
//  PostAPI.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import Foundation
import Moya
import RxSwift

enum PostService {
    case add(param: PostParams.AddPostRequest)
    case fileUpload(param: PostParams.FileUploadRequest)
}

extension PostService: TargetType {
    var baseURL: URL {
        return APIService.shared.baseURL
    }
    
    var path: String {
        switch self {
        case .add:
            return "/v1/posts"
        case .fileUpload:
            return "/v1/posts/files"
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
        case .add(let param):
            return .requestJSONEncodable(param)
        case .fileUpload(let param):
            return .uploadMultipart(param.convertMultiPartFormData())
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fileUpload:
            return [
                Header.authorization.rawValue: UserDefaultsManager.shared.token,
                Header.contentType.rawValue: Header.multipart.rawValue,
                Header.sesacKey.rawValue: APIInfo.key
            ]
        default:
            return [
                Header.authorization.rawValue: UserDefaultsManager.shared.token,
                Header.contentType.rawValue: Header.json.rawValue,
                Header.sesacKey.rawValue: APIInfo.key
            ]
        }
    }
}

class PostAPI {
    private init(){}
    static let shared = PostAPI()
    
    let provider = MoyaProvider<PostService>(plugins: [MoyaLoggingPlugin()])
    
    func networking<T: Codable>(service: PostService, type: T.Type) -> Single<NetworkResult<T>> {
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
                    return print("error - \(error)")
                }
            }
            
            return Disposables.create()
        }
    }
}
