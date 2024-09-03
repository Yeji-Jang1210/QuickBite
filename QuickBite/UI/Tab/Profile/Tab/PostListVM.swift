//
//  PostListVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/27/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostListVM: BaseVM, BaseVMProvider {
    struct Input {
        let callPostAPI: PublishRelay<Void>
        let modelSelected: ControlEvent<Post>
    }
    
    struct Output {
        let sectionModels: Observable<[PostSectionModel]>
        let toastMessage: PublishRelay<String>
        let modelSelected: ControlEvent<Post>
    }
    
    var type: PostType!
    
    init(type: PostType){
        self.type = type
    }
    
    func transform(input: Input) -> Output {
        let postData = PublishRelay<[PostParams.PostResponse]>()
        let toastMessage = PublishRelay<String>()
        
        input.callPostAPI
            .compactMap { self.type }
            .flatMap {
                switch $0 {
                case .userPost:
                    return Observable.just(PostParams.FetchUserPostsRequest(id: UserDefaultsManager.shared.userId))
                        .flatMap {
                            PostAPI.shared.networking(service: .fetchUserPosts(param: $0), type: PostParams.FetchUserPostsResponse.self)
                        }
                case .bookmark:
                    return Observable.just(PostParams.FetchUserLikePostRequest())
                        .flatMap {
                            PostAPI.shared.networking(service: .fetchUserLikesPost(param: $0), type: PostParams.FetchUserPostsResponse.self)
                        }
                }
            }
            .bind { networkResult in
                switch networkResult {
                case .success(let success):
                    postData.accept(success.data)
                case .error(let statusCode):
                    guard let error = FetchUserPostError(rawValue: statusCode) else {
                        toastMessage.accept("알수없는 오류")
                        return
                    }
                    
                    toastMessage.accept(error.message)
                }
            }
            .disposed(by: disposeBag)
        
        let post = postData
            .compactMap { responses -> [Post] in
                let posts: [Post] = responses.compactMap { response in
                    guard let recipe = try? JSONDecoder().decode(Recipe.self, from: Data(response.content.utf8)) else {
                        return nil
                    }
                    
                    let post = Post(
                        post_id: response.post_id,
                        product_id: response.product_id,
                        title: response.title,
                        content: recipe,
                        createdAt: response.createdAt,
                        creator: response.creator,
                        files: response.files,
                        likes: response.likes,
                        buyers: response.buyers,
                        price: response.price
                    )
                    
                    return post
                }
                
                return posts
            }
            .map{
                [PostSectionModel(items: $0)]
            }
        
        return Output(sectionModels: post, 
                      toastMessage: toastMessage,
                      modelSelected: input.modelSelected)
    }
}
