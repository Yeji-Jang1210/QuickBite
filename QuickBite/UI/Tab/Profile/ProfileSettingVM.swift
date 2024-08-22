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
    
    private var user: [SettingInfo] = []
    
    init(_ user: [String:String?]){
        for type in ProfileInfo.allCases {
            if let value = user[type.rawValue] {
                self.user.append(SettingInfo(type: type, value: value ?? ""))
            }
        }
        
        dump(self.user)
    }
    
    struct Input {
        let itemSelected: ControlEvent<SettingInfo>
    }
    
    struct Output {
        let infoItems: Driver<[ProfileSettingSectionModel]>
        let selectedItem: PublishRelay<SettingInfo>
    }
    
    func transform(input: Input) -> Output {
        
        let info = BehaviorRelay(value: user)
        let selectedItem = PublishRelay<SettingInfo>()
        let logoutSelected = PublishRelay<Bool>()
        let withDrawSelected = PublishRelay<Bool>()
        
        let infoItems = info
            .compactMap{ $0 }
            .map {
                [ProfileSettingSectionModel(header: "개인설정", items: $0),
                 ProfileSettingSectionModel(header: "로그인", items: [SettingInfo(type: .logout, value: ""), SettingInfo(type: .withdraw, value: "")])]
            }
            .asDriver(onErrorJustReturn: [])
        
        input.itemSelected
            .bind { info in
                switch info.type {
                case .email:
                    break
                case .logout:
                    logoutSelected.accept(true)
                case .withdraw:
                    withDrawSelected.accept(true)
                default:
                    selectedItem.accept(info)
                }
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(infoItems: infoItems, selectedItem: selectedItem)
    }
}
