//
//  MainVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import UIKit
import RxSwift
import RxCocoa

// 더미 Recipe 데이터 (한글)

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
                        files: response.files
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
    
    func convertPost(_ data: Observable<[PostParams.PostResponse]>) -> Driver<[PostSectionModel]>{
        return data
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
                        files: response.files
                    )
                    
                    return post
                }
                
                return posts
            }
            .map{
                [PostSectionModel(items: $0)]
            }
            .asDriver(onErrorJustReturn: [])
        
    }
}
