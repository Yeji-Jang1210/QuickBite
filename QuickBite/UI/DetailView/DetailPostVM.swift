//
//  DetailPostVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailPostVM: BaseVM, BaseVMProvider {
    
    struct Input {
        let presentVC: PublishRelay<Void>
        let dismissButtonTap: ControlEvent<Void>
        let bookmarkButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let presentVC: Observable<Post>
        let dismissButtonTap: ControlEvent<Void>
        let backgroundImageURL: Driver<URL?>
        let bookmarkButtonIsSelected: Driver<Bool>
        let toastMessage: Driver<String>
    }
    
    private var post: Post!
    
    init(post: Post){
        self.post = post
    }
    
    func transform(input: Input) -> Output {
        let isSelectBookmark = BehaviorRelay(value: post.likes.contains(UserDefaultsManager.shared.userId))
        let receiveToastMessage = PublishRelay<String>()

        let post = Observable.just(post)
            .compactMap{ $0 }
        
        let backgroundImageURL = post
            .compactMap{ $0.files.last }
            .compactMap{ URL(string: "\(APIInfo.baseURL)/v1/\($0)") }
            .asDriver(onErrorJustReturn: nil)
        
        input.bookmarkButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(isSelectBookmark)
            .bind{ isSelected in
                isSelectBookmark.accept(!isSelected)
                self.callBookmarkAPI(isSelected: isSelected) { result in
                    receiveToastMessage.accept(result ? "저장되었습니다" : "삭제되었습니다")
                }
            }
            .disposed(by: disposeBag)
        
        let isSelectedBookmark = isSelectBookmark.asDriver(onErrorJustReturn: false)
        let toastMessage = receiveToastMessage.asDriver(onErrorJustReturn: "")
        
        return Output(presentVC: post,
                      dismissButtonTap: input.dismissButtonTap,
                      backgroundImageURL: backgroundImageURL,
                      bookmarkButtonIsSelected: isSelectedBookmark, toastMessage: toastMessage)
    }
    
    func callBookmarkAPI(isSelected: Bool, completion: @escaping (Bool) -> Void){
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
                    NotificationCenter.default.post(name: .updateBookmarkCount, object: success.like_status)
                    completion(success.like_status)
                case .error(let statusCode):
                    print("\(statusCode)")
                }
            }
            .disposed(by: disposeBag)
    }
    
    
}
