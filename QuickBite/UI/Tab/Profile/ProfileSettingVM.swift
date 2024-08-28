//
//  ProfileSettingVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/21/24.
//

import Foundation
import RxSwift
import RxCocoa

struct SettingInfo: Equatable {
    let type: ProfileInfo
    let value: String
}

final class ProfileSettingVM: BaseVM, BaseVMProvider {
    
    private var user: [String: String?] = [:]
    
    init(_ user: [String:String?]){
        self.user = user
    }
    
    struct Input {
        let profileImageEditButtonTap: ControlEvent<Void>
        let itemSelected: ControlEvent<SettingInfo>
        let alertOkButtonTap: PublishRelay<ProfileInfo>
        let profileImage: PublishRelay<Data>
        let profileImageName: PublishRelay<String>
    }
    
    struct Output {
        let profileImageEditButtonTap: ControlEvent<Void>
        let imagePath: Driver<String?>
        let infoItems: Driver<[ProfileSettingSectionModel]>
        let selectedItem: PublishRelay<(ProfileInfo, [String: String?])>
        let showAlert: PublishRelay<ProfileInfo>
        let loginViewWillPresent: PublishRelay<Void>
        let toastMessage: PublishRelay<String>
        let rootViewWillPresent: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let info = BehaviorRelay(value: user)
        let selectedItem = PublishRelay<(ProfileInfo, [String: String?])>()
        let showAlert = PublishRelay<ProfileInfo>()
        let callwithDraw = PublishRelay<Void>()
        let loginViewWillPresent = PublishRelay<Void>()
        let toastMessage = PublishRelay<String>()
        let rootViewWillPresent = PublishRelay<Void>()
        
        let infoItems = info
            .compactMap { dict in
                ProfileInfo.allCases.compactMap { type in
                    dict[type.rawValue].map { SettingInfo(type: type, value: $0 ?? "") }
                }
            }
            .map {
                [ProfileSettingSectionModel(header: "개인설정", items: $0),
                 ProfileSettingSectionModel(header: "로그인", items: [SettingInfo(type: .logout, value: ""), SettingInfo(type: .withdraw, value: "")])]
            }
            .asDriver(onErrorJustReturn: [])
        
        let imagePath = Observable.just(user["profileImage"])
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: nil)
        
        input.itemSelected
            .bind(with: self){ owner, info in
                switch info.type {
                case .email:
                    break
                case .logout:
                    showAlert.accept(info.type)
                case .withdraw:
                    showAlert.accept(info.type)
                default:
                    selectedItem.accept((info.type, owner.user))
                }
            }
            .disposed(by: disposeBag)
       
        input.alertOkButtonTap
            .bind(with: self){ owner, type in
                switch type {
                case .logout:
                    UserDefaultsManager.shared.reset()
                    loginViewWillPresent.accept(())
                case .withdraw:
                    callwithDraw.accept(())
                default:
                    return
                }
            }
            .disposed(by: disposeBag)
      
        callwithDraw
            .flatMap { _ in
                UserAPI.shared.networking(service: .withdraw, type: Userparams.WithDrawResponse.self)
            }
            .subscribe(with: self){ owner, networkResult in
                switch networkResult {
                case .success(_):
                    UserDefaultsManager.shared.reset()
                    loginViewWillPresent.accept(())
                case .error(let statusCode):
                    switch statusCode {
                    case 401:
                        toastMessage.accept("인증할 수 없는 액세스 토큰입니다.")
                    case 403:
                        toastMessage.accept("접근 권한이 없습니다.")
                    default:
                        toastMessage.accept("회원 탈퇴에 실패했습니다.")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        Observable.zip(input.profileImage, input.profileImageName)
            .map { [weak self] data, name in
                Userparams.EditRequest(
                    nick: self?.user[ProfileInfo.nick.rawValue] ?? nil,
                    phoneNum: self?.user[ProfileInfo.phoneNum.rawValue] ?? nil,
                    birthDay: self?.user[ProfileInfo.birthday.rawValue] ?? nil,
                    profile: data,
                    prorilfeImageName: name
                )
            }
            .flatMap {
                UserAPI.shared.networking(service: .edit(param: $0), type: Userparams.EditResponse.self)
            }
            .subscribe(with: self){ owner, networkResult in
                switch networkResult {
                case .success(_):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        rootViewWillPresent.accept(())
                    }
                case .error(let statusCode):
                    guard let error = EditProfileError(rawValue: statusCode) else {
                        toastMessage.accept("알수없는 오류")
                        return
                    }
                    
                    toastMessage.accept(error.message)
                }
            }
            .disposed(by: disposeBag)
        

        return Output(profileImageEditButtonTap: input.profileImageEditButtonTap, 
                      imagePath: imagePath,
                      infoItems: infoItems,
                      selectedItem: selectedItem,
                      showAlert: showAlert,
                      loginViewWillPresent: loginViewWillPresent,
                      toastMessage: toastMessage, 
                      rootViewWillPresent: rootViewWillPresent)
    }
}
