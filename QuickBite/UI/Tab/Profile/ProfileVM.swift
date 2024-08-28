//
//  ProfileVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileVM: BaseVM, BaseVMProvider {
    
    struct Input {
        let callProfileAPI: PublishRelay<Void>
        let settingBarButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let nickname: Driver<String>
        let email: Driver<String>
        let birthday: Driver<String>
        let birthdayIsEmpty: Driver<Bool>
        let imagePath: Driver<String?>
        let presentProfileSetting: PublishRelay<[String:String?]>
        let sectionModels: Driver<[PostSectionModel]>
        let errorMessage: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        
        let presentProfileSetting = PublishRelay<[String:String?]>()
        let callErrorMessage = PublishRelay<String>()
        let callPostAPI = PublishRelay<String>()
        let postData = PublishRelay<[PostParams.PostResponse]>()
        
        let user = input.callProfileAPI
            .flatMap {
                UserAPI.shared.networking(service: .load, type: Userparams.LoadResponse.self)
            }
            .compactMap { networkResult in
                switch networkResult {
                case .success(let result):
                    callPostAPI.accept(result.userId)
                    return result
                case .error(let statusCode):
                    print("\(statusCode)")
                }
                return nil
            }
            .asDriver(onErrorJustReturn: Userparams.LoadResponse(userId: "", email: "", nick: "", phoneNum: "", birthDay: "", profileImage: "", posts: []))
            
        
        let nickname = user
            .compactMap{ $0.nick }
            .asDriver(onErrorJustReturn: "")
        
        let email = user
            .compactMap{ $0.email }
            .asDriver(onErrorJustReturn: "")
        
        let birthdayIsEmpty = user
                                .compactMap{ $0.birthDay }
                                .map { $0.isEmpty }
                                .asDriver(onErrorJustReturn: true)
        
        let birthday = user
            .compactMap{ $0.birthDay }
            .filter { !$0.isEmpty }
            .map {ValidationBirthday.format($0)}
            .asDriver(onErrorJustReturn: "")
            
        let imagePath = user
            .map{ $0.profileImage }
            .asDriver(onErrorJustReturn: nil)
        
        input.settingBarButtonTap
            .withLatestFrom(user.asObservable())
            .map { user in
                return [
                    "profileImage": user.profileImage,
                    "email": user.email,
                    "nick": user.nick,
                    "birthday": user.birthDay,
                    "phoneNum": user.phoneNum
                ]
            }
            .subscribe{ user in
                presentProfileSetting.accept(user)
            }
            .disposed(by: disposeBag)
        
        let errorMessage = callErrorMessage.asDriver(onErrorJustReturn: "")
        
        callPostAPI
            .debug("call user post api")
            .map {
                return PostParams.FetchUserPostsRequest(id: $0)
            }
            .flatMap {
                PostAPI.shared.networking(service: .fetchUserPosts(param: $0), type: PostParams.FetchUserPostsResponse.self)
            }
            .bind { networkResult in
                switch networkResult {
                case .success(let success):
                    postData.accept(success.data)
                case .error(let statusCode):
                    guard let error = FetchUserPostError(rawValue: statusCode) else {
                        callErrorMessage.accept("알수없는 오류")
                        return
                    }
                    
                    callErrorMessage.accept(error.message)
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
        
        return Output(nickname: nickname,
                      email: email,
                      birthday: birthday, 
                      birthdayIsEmpty: birthdayIsEmpty,
                      imagePath: imagePath,
                      presentProfileSetting: presentProfileSetting, 
                      sectionModels: post,
                      errorMessage: errorMessage)
    }
}
