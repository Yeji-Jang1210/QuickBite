//
//  MainVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import UIKit
import RxSwift
import RxCocoa

final class MainVM: BaseVM, BaseVMProvider {
    
    struct Input {
        let callPostAPI: PublishRelay<Void>
        let addPostButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let addPostButtonTap: ControlEvent<Void>
        let items: Driver<[PostSectionModel]>
    }
    
    func transform(input: Input) -> Output {
        
        let data = PublishRelay<[PostParams.PostResponse]>()
        
        input.callPostAPI
            .debug("call main post API")
            .map { PostParams.FetchPosts(limit: "10") }
            .flatMap {
                PostAPI.shared.networking(service: .fetchPosts(param: $0), type: PostParams.FetchUserPostsResponse.self)
            }
            .bind { networkResult in
                switch networkResult {
                case .success(let success):
                    data.accept(success.data)
                case .error(let statusCode):
                    print(statusCode)
                }
            }
            .disposed(by: disposeBag)
        
        let items = data
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
                        likes: response.likes
                    )
                    
                    return post
                }
                
                return posts
            }
            .map{
                [PostSectionModel(items: $0)]
            }
            .asDriver(onErrorJustReturn: [])
        
        return Output(addPostButtonTap: input.addPostButtonTap, items: items)
    }
    
    func callBookmarkAPI(post: Post, isSelected: Bool, completion: @escaping (Bool) -> Void){
        Observable.just(post)
            .debug("call Bookmark API")
            .map{ post -> (String, PostParams.LikeRequest)? in
                return (post.post_id, PostParams.LikeRequest(isLike: !isSelected))
            }
            .compactMap{ $0 }
            .flatMap { (id, param) in
                PostAPI.shared.networking(service: .like(id: id, param: param), type: PostParams.LikeResponse.self)
            }
            .bind(with: self) { owner, networkResult in
                switch networkResult {
                case .success(let success):
                    completion(success.like_status)
                case .error(let statusCode):
                    print("\(statusCode)")
                }
            }
            .disposed(by: disposeBag)
    }
}
