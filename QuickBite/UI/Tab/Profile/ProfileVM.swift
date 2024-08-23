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
        let settingBarButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let nickname: Driver<String>
        let email: Driver<String>
        let birthday: Driver<String>
        let birthdayIsEmpty: Driver<Bool>
        let imagePath: Driver<String?>
        let presentProfileSetting: PublishRelay<[String:String?]>
    }
    
    func transform(input: Input) -> Output {
        
        let presentProfileSetting = PublishRelay<[String:String?]>()
        
        let user = UserAPI.shared.networking(service: .load, type: Userparams.LoadResponse.self)
            .compactMap { networkResult in
                switch networkResult {
                case .success(let result):
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
            .map { text in
                let yearStartIndex = text.index(text.startIndex, offsetBy: 4)
                let year = "\(text[text.startIndex..<yearStartIndex])"
                
                let monthStartIndex = text.index(text.startIndex, offsetBy: 4) //5
                let month = "\(text[monthStartIndex..<text.index(monthStartIndex, offsetBy: 2)])"


                let dayStartIndex = text.index(monthStartIndex, offsetBy: 2)
                let day = "\(text[dayStartIndex..<text.index(dayStartIndex, offsetBy:2)])"
                
                return Localized.birthday_format(year: year, month: month, day: day).text
            }
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
        
        return Output(nickname: nickname,
                      email: email,
                      birthday: birthday, 
                      birthdayIsEmpty: birthdayIsEmpty,
                      imagePath: imagePath,
                      presentProfileSetting: presentProfileSetting)
    }
}
