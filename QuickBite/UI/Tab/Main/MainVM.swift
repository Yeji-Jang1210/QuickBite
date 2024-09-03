//
//  MainVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import iamport_ios

final class MainVM: BaseVM, BaseVMProvider {
    
    struct Input {
        let callPostAPI: PublishRelay<Void>
        let callMealKitPostAPI: PublishRelay<Void>
        let passPaymentInfo: PublishRelay<Post>
        let addPostButtonTap: ControlEvent<Void>
        let modelSelected: ControlEvent<Post>
    }
    
    struct Output {
        let addPostButtonTap: ControlEvent<Void>
        let items: Driver<[PostSectionModel]>
        let modelSelected: ControlEvent<Post>
        let mealKitItems: Driver<[PostSectionModel]>
        let payment: Observable<(IamportPayment, Post)>
        let toastMessage: PublishRelay<String>
    }
    
    let toastMessage = PublishRelay<String>()
    
    func transform(input: Input) -> Output {
        
        let data = PublishRelay<[PostParams.PostResponse]>()
        let mealKitData = PublishRelay<[PostParams.PostResponse]>()
        
        input.callPostAPI
            .debug("call main post API")
            .map { PostParams.FetchPosts(next: "", limit: "10") }
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
        
        input.callMealKitPostAPI
            .debug("call mealkit post API")
            .map { PostParams.FetchUserPostsRequest(id: APIInfo.paymentUserId) }
            .flatMap {
                PostAPI.shared.networking(service: .fetchUserPosts(param: $0), type: PostParams.FetchUserPostsResponse.self)
            }
            .bind { networkResult in
                switch networkResult {
                case .success(let success):
                    mealKitData.accept(success.data)
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
            .asDriver(onErrorJustReturn: [])
        
        let mealKitItems = mealKitData
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
            .asDriver(onErrorJustReturn: [])
        
        let payment = input.passPaymentInfo
            .flatMap { post in
                return Observable.just((IamportPayment(pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                                              merchant_uid: "ios_\(APIInfo.key)_\(Int(Date().timeIntervalSince1970))",
                                              amount: "100")
                     .then {
                         $0.pay_method = PayMethod.card.rawValue
                         $0.name = "\(post.title)"
                         $0.buyer_name = "장예지"
                         $0.app_scheme = "sesac"
                     }, post))
            }
        
        return Output(addPostButtonTap: input.addPostButtonTap,
                      items: items,
                      modelSelected: input.modelSelected,
                      mealKitItems: mealKitItems, 
                      payment: payment,
                      toastMessage: toastMessage)
    }
    
    func callBookmarkAPI(post: Post, isSelected: Bool, completion: @escaping (Bool) -> Void){
        Observable.just(post)
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
    
    func validatePaymentResponse(_ response: IamportResponse, _ post: Post){
        if let imp_uid = response.imp_uid {
            let request = PaymentParams.ValidationRequest(imp_uid: imp_uid, post_id: post.post_id)
            
            PaymentAPI.shared.networking(service: .validation(param: request), type: PaymentParams.ValidationResponse.self)
                .subscribe(with: self) { owner, networkResult in
                    switch networkResult {
                    case .success(let success):
                        dump(success)
                        owner.toastMessage.accept("구매가 완료되었습니다.")
                    case .error(let statusCode):
                        guard let error = PaymentError(rawValue: statusCode) else {
                            owner.toastMessage.accept("알수없는 오류입니다.")
                            return
                        }
                        
                        owner.toastMessage.accept(error.message)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
}
