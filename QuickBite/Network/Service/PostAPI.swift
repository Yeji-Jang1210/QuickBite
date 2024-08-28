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
    case fetchUserPosts(param: PostParams.FetchUserPostsRequest)
    case fetchPosts(param: PostParams.FetchPosts)
    case fetchSpecificPost(param: PostParams.FetchSpecificPostRequest)
}

extension PostService: TargetType {
    
    var validationType: ValidationType {
        return .successCodes
    }
    
    var baseURL: URL {
        return APIService.shared.baseURL
    }
    
    var path: String {
        switch self {
        case .add, .fetchPosts:
            return "/v1/posts"
        case .fileUpload:
            return "/v1/posts/files"
        case .fetchSpecificPost(let param):
            return "/v1/posts/\(param.id)"
        case .fetchUserPosts(let param):
            return "/v1/posts/users/\(param.id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .add, .fileUpload:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .add(let param):
            return .requestJSONEncodable(param)
        case .fileUpload(let param):
            return .uploadMultipart(param.convertMultiPartFormData())
        case .fetchPosts(param: let param):
            return .requestParameters(parameters: param.toParameters(), encoding: URLEncoding.queryString)
        case .fetchUserPosts, .fetchSpecificPost:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .fetchPosts, .fetchSpecificPost:
            return [
                Header.authorization.rawValue: UserDefaultsManager.shared.token,
                Header.sesacKey.rawValue: APIInfo.key
            ]
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
    
    let provider = MoyaProvider<PostService>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
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
                    single(.success(.error(error.errorCode)))
                }
            }
            
            return Disposables.create()
        }
    }
}
