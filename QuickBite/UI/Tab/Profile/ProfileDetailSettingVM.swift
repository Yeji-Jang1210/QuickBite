//
//  ProfileDetailSettingVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileDetailSettingVM: BaseVM, BaseVMProvider {
    
    private let type: ProfileInfo!
    private var value: [String: String?]!
    
    struct Input {
        let text: ControlProperty<String>
        let saveButtonTapped: ControlEvent<Void>
    }
    
    struct Output {
        let isValid: Driver<Bool>
        let validMessage: PublishRelay<String>
        let phoneNumber: PublishRelay<String>
        let rootViewWillPresent: PublishRelay<Void>
        let toastMessage: PublishRelay<String>
    }
    
    init(_ info: (ProfileInfo, [String: String?])){
        self.type = info.0
        self.value = info.1
    }
    
    func transform(input: Input) -> Output {
        
        let isValidResult = PublishRelay<Bool>()
        let validMessage = PublishRelay<String>()
        let rootViewWillPresent = PublishRelay<Void>()
        let toastMessage = PublishRelay<String>()
        let phoneNumber = PublishRelay<String>()
        
        //phoneNumber bugfix 필요
        input.text
            .bind(with: self){ owner, text in
                switch owner.type {
                case .nick:
                    let result = !text.contains(" ") && text.count > 2
                    validMessage.accept(result ? "" : "3자리 이상 공백 없이 입력해주세요.")
                    isValidResult.accept(result)
                case .birthday:
                    ValidationBirthday.validateBirthday(text) { result in
                        validMessage.accept(result.message)
                        isValidResult.accept(result.isValid)
                    }
                case .phoneNum:
                    ValidationPhoneNumber.validatePhoneNumber(text) { result in
                        isValidResult.accept(result.isValid)
                        validMessage.accept(result.message)
                        
                        if result == .isNumber {
                            phoneNumber.accept(ValidationPhoneNumber.format(phoneNumber: text))
                        }
                    }
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        let isValid = isValidResult
            .asDriver(onErrorJustReturn: false)
        
        input.saveButtonTapped
            .withLatestFrom(input.text)
            .map { [weak self] text in
                if let rawValue = self?.type.rawValue {
                    self?.value[rawValue] = text
                }
            }
            .map { [weak self] _ in
                Userparams.EditRequest(
                    nick: self?.value[ProfileInfo.nick.rawValue] ?? nil,
                    phoneNum: self?.value[ProfileInfo.phoneNum.rawValue] ?? nil,
                    birthDay: self?.value[ProfileInfo.birthday.rawValue] ?? nil,
                    profile: nil,
                    prorilfeImageName: nil
                )
            }
            .flatMap {
                UserAPI.shared.networking(service: .edit(param: $0), type: Userparams.EditResponse.self)
            }
            .subscribe(with: self){ owner, networkResult in
                switch networkResult {
                case .success(let result):
                    toastMessage.accept("\(owner.type.title) 변경에 성공했습니다.")
                    
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

        return Output(isValid: isValid,
                      validMessage: validMessage,
                      phoneNumber: phoneNumber,
                      rootViewWillPresent: rootViewWillPresent,
                      toastMessage: toastMessage)
    }
}
