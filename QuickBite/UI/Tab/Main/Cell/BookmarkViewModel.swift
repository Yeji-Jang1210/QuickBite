//
//  BookmarkViewModel.swift
//  QuickBite
//
//  Created by 장예지 on 8/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BookmarkViewModel: BaseVM, BaseVMProvider {
    
    let post: Post!
    
    struct Input {
        let bookmarkButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let bookmarkIsSelected: BehaviorRelay<Bool>
        let title: Driver<String>
        let servingsText: Driver<String>
        let timeText: Driver<String>
        let thumbnailImage: Driver<URL?>
    }
    
    init(_ post: Post){
        self.post = post
    }
    
    func transform(input: Input) -> Output {
        let isSelected = BehaviorRelay<Bool>(value: post.likes.contains(UserDefaultsManager.shared.userId))

        input.bookmarkButtonTap
            .debug("bookmarkButtonTap")
            .map { [weak self] _ -> (String, PostParams.LikeRequest)? in
                guard let self else { return nil }
                return (post.post_id, PostParams.LikeRequest(isLike: !isSelected.value))
            }
            .compactMap{ $0 }
            .flatMap { (id, param) in
                PostAPI.shared.networking(service: .like(id: id, param: param), type: PostParams.LikeResponse.self)
            }
            .bind(with: self) { owner, networkResult in
                switch networkResult {
                case .success(let success):
                    isSelected.accept(success.like_status)
                case .error(let statusCode):
                    print("\(statusCode)")
                }
            }
            .disposed(by: disposeBag)
        
        let title = Observable.just(post.title)
            .asDriver(onErrorJustReturn: "")
        
        let servingsText = Observable.just(post.content.servings)
            .flatMap { Observable.just("\($0)인분") }
            .asDriver(onErrorJustReturn: "")
        
        let timeText = Observable.just(post.content.time)
            .flatMap { Observable.just("\($0)분") }
            .asDriver(onErrorJustReturn: "")
        
        let thumbnailImage = Observable.just(post.files.last)
            .compactMap{ $0 }
            .flatMap { Observable.just(URL(string: "\(APIInfo.baseURL)/v1/\($0)")) }
            .asDriver(onErrorJustReturn: nil)
            
        
        return Output(bookmarkIsSelected: isSelected,
                      title: title,
                      servingsText: servingsText,
                      timeText: timeText,
                      thumbnailImage: thumbnailImage)
    }
}
