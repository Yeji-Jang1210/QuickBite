//
//  ProfileVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/20/24.
//

import Foundation
import RxSwift
import RxCocoa

struct DisplayProfile: Codable {
    let userId: String
    let nickname: String
    let profile: String?
    let birthday: String?
    let phoneNumber: String?
    let email: String?
    let posts: [String]
    let followers: [Creator]
    let following: [Creator]
}

enum ProfileType {
    case isUser
    case otherUser(userId: String)
    
    var userId: String {
        switch self {
        case .isUser:
            return UserDefaultsManager.shared.userId
        case .otherUser(let userId):
            return userId
        }
    }
    
    func convertDisplayProfileInfo(_ result: Userparams.LoadResponse) -> DisplayProfile {
        return DisplayProfile(userId: result.userId,
                              nickname: result.nick,
                              profile: result.profileImage,
                              birthday: result.birthDay,
                              phoneNumber: result.phoneNum,
                              email: result.email,
                              posts: result.posts,
                              followers: result.followers,
                              following: result.following)
    }
    
    func convertDisplayProfileInfo(_ result: Userparams.OtherUserResponse) -> DisplayProfile {
        return DisplayProfile(userId: result.userId,
                              nickname: result.nick,
                              profile: result.profileImage,
                              birthday: nil,
                              phoneNumber: nil,
                              email: nil,
                              posts: result.posts,
                              followers: result.followers,
                              following: result.following)
    }
}

final class ProfileVM: BaseVM, BaseVMProvider {
    
    struct Input {
        let callProfileAPI: PublishRelay<Void>
        let settingBarButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let profileType: Driver<ProfileType>
        let nickname: Driver<String>
        let email: Driver<String>
        let birthday: Driver<String>
        let birthdayIsEmpty: Driver<Bool>
        let imagePath: Driver<String?>
        let presentProfileSetting: PublishRelay<[String:String?]>
        let postCount: Driver<String>
        let followersCount: Driver<String>
        let followingCount: Driver<String>
        let errorMessage: Driver<String>
    }
    
    let type: ProfileType
    
    init(type: ProfileType) {
        self.type = type
    }
    
    func transform(input: Input) -> Output {
        
        let presentProfileSetting = PublishRelay<[String:String?]>()
        let callErrorMessage = PublishRelay<String>()
        
        let type = Observable.just(type)
            .asDriver(onErrorJustReturn: .isUser)
        
        let user = input.callProfileAPI
            .flatMap { [weak self] _ in
                guard let self else { return Single<ProfileResult<DisplayProfile>>.never() }
                return convertDisplayProfileInfo()
            }
            .compactMap { response in
                switch response {
                case .success(let result):
                    return result
                case .error(let statusCode):
                    print(statusCode)
                }
                
                return nil
            }
            .asDriver(onErrorJustReturn: DisplayProfile(userId: "", nickname: "", profile: "", birthday: "", phoneNumber: "", email: "", posts: [], followers: [], following: []))
        
        
        let nickname = user
            .compactMap{ $0.nickname }
            .asDriver(onErrorJustReturn: "")
        
        let email = user
            .compactMap{ $0.email }
            .asDriver(onErrorJustReturn: "")
        
        let birthdayIsEmpty = user
            .compactMap{ $0.birthday }
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: true)
        
        let birthday = user
            .compactMap{ $0.birthday }
            .filter { !$0.isEmpty }
            .map {ValidationBirthday.format($0)}
            .asDriver(onErrorJustReturn: "")
        
        let imagePath = user
            .map{ $0.profile }
            .asDriver(onErrorJustReturn: nil)
        
        let postCount = user
            .map { "\($0.posts.count)" }
            .asDriver(onErrorJustReturn: "0")
        
        let followersCount = user
            .map { "\($0.followers.count)" }
            .asDriver(onErrorJustReturn: "0")
        
        let followingCount = user
            .map { "\($0.following.count)" }
            .asDriver(onErrorJustReturn: "0")
        
        input.settingBarButtonTap
            .withLatestFrom(user.asObservable())
            .map { user in
                return [
                    "profileImage": user.profile,
                    "email": user.email,
                    "nick": user.nickname,
                    "birthday": user.birthday,
                    "phoneNum": user.phoneNumber
                ]
            }
            .subscribe{ user in
                presentProfileSetting.accept(user)
            }
            .disposed(by: disposeBag)
        
        let errorMessage = callErrorMessage.asDriver(onErrorJustReturn: "")
        
        return Output(profileType: type,
                      nickname: nickname,
                      email: email,
                      birthday: birthday,
                      birthdayIsEmpty: birthdayIsEmpty,
                      imagePath: imagePath,
                      presentProfileSetting: presentProfileSetting,
                      postCount: postCount,
                      followersCount: followersCount,
                      followingCount: followingCount,
                      errorMessage: errorMessage)
    }
    
    func convertDisplayProfileInfo() -> Single<ProfileResult<DisplayProfile>> {
        return Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            switch type {
            case .isUser:
                UserAPI.shared.networking(service: .load, type: Userparams.LoadResponse.self)
                    .subscribe(with: self){ owner, networkResult in
                        switch networkResult {
                        case .success(let result):
                            single(.success(.success(owner.type.convertDisplayProfileInfo(result))))
                        case .error(let statusCode):
                            single(.success(.error(statusCode)))
                        }
                    }
                    .disposed(by: disposeBag)
                
            case .otherUser:
                UserAPI.shared.networking(service: .otherUserProfile(userId: type.userId), type: Userparams.OtherUserResponse.self)
                    .subscribe(with: self){ owner, networkResult in
                        switch networkResult {
                        case .success(let result):
                            single(.success(.success(owner.type.convertDisplayProfileInfo(result))))
                        case .error(let statusCode):
                            single(.success(.error(statusCode)))
                        }
                    }
                    .disposed(by: disposeBag)
            }
            return Disposables.create()
        }
    }
}

enum ProfileResult<DisplayProfile>{
    case success(DisplayProfile)
    case error(Int)
}
