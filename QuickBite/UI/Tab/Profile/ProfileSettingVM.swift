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
        let itemSelected: ControlEvent<SettingInfo>
        let alertOkButtonTap: PublishRelay<ProfileInfo>
    }
    
    struct Output {
        let infoItems: Driver<[ProfileSettingSectionModel]>
        let selectedItem: PublishRelay<(ProfileInfo, [String: String?])>
        let showAlert: PublishRelay<ProfileInfo>
        let loginViewWillPresent: PublishRelay<Void>
        let errorMessage: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        
        let info = BehaviorRelay(value: user)
        let selectedItem = PublishRelay<(ProfileInfo, [String: String?])>()
        let showAlert = PublishRelay<ProfileInfo>()
        let logoutSelected = PublishRelay<Bool>()
        let withDrawSelected = PublishRelay<Bool>()
        let callwithDraw = PublishRelay<Void>()
        let loginViewWillPresent = PublishRelay<Void>()
        let errorMessage = PublishRelay<String>()
        
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
                    owner.resetToken()
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
                case .success(let _):
                    owner.resetToken()
                    loginViewWillPresent.accept(())
                case .error(let statusCode):
                    switch statusCode {
                    case 401:
                        errorMessage.accept("인증할 수 없는 액세스 토큰입니다.")
                    case 403:
                        errorMessage.accept("접근 권한이 없습니다.")
                    default:
                        errorMessage.accept("회원 탈퇴에 실패했습니다.")
                    }
                }
            }
            .disposed(by: disposeBag)

        return Output(infoItems: infoItems,
                      selectedItem: selectedItem,
                      showAlert: showAlert,
                      loginViewWillPresent: loginViewWillPresent,
                      errorMessage: errorMessage)
    }
    
    func resetToken(){
        UserDefaultsManager.shared.token = ""
        UserDefaultsManager.shared.refreshToken = ""
    }
}
