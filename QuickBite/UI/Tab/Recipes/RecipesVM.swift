//
//  RecipesVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/31/24.


import Foundation
import RxSwift
import RxCocoa

final class RecipesVM: BaseVM, BaseVMProvider {
    struct Input {
        let callPostAPI: PublishRelay<Void>
        let modelSelected: ControlEvent<Post>
    }
    
    struct Output {
        let items: Driver<[PostSectionModel]>
        let Cursor: BehaviorRelay<String>
        let isLastPage: BehaviorRelay<Bool>
        let modelSelected: ControlEvent<Post>
    }
    
    let data = PublishRelay<[PostParams.PostResponse]>()
    var isFirstPage = true
    var items: [PostParams.PostResponse] = []
    let nextCursor = BehaviorRelay(value: "")
    
    func transform(input: Input) -> Output {
        
        let isLastPage = BehaviorRelay(value: false)
        
        input.callPostAPI
            .debug("call post api 호출")
            .withLatestFrom(nextCursor)
            .map {
                PostParams.FetchPosts(next: "\($0)", limit: "10")
            }
            .flatMap {
                PostAPI.shared.networking(service: .fetchPosts(param: $0), type: PostParams.FetchUserPostsResponse.self)
            }
            .bind(with: self) { owner, networkResult in
                switch networkResult {
                case .success(let success):
                    owner.items.append(contentsOf: success.data)
                    owner.data.accept(owner.items)
                    
                    print("lastData next cursor: \(success.next_cursor)")
                    
                    owner.nextCursor.accept(success.next_cursor)
                    isLastPage.accept(success.next_cursor == "0" ? true : false)
                    
                case .error(let statusCode):
                    print(statusCode)
                }
            }
            .disposed(by: disposeBag)
        
        let items = self.data
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
        
        return Output(items: items,
                      Cursor: nextCursor,
                      isLastPage: isLastPage, 
                      modelSelected: input.modelSelected)
    }
}
