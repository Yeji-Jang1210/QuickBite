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
    
    private let info: ProfileInfo!
    
    struct Input {
        let text: ControlProperty<String>
    }
    
    struct Output {
        let isValid: Driver<Bool>
        let validMessage: PublishRelay<String>
    }
    
    init(info: ProfileInfo){
        self.info = info
    }
    
    func transform(input: Input) -> Output {
        
        let isValidResult = PublishRelay<Bool>()
        let validMessage = PublishRelay<String>()
        
        input.text
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .debug("텍스트")
            .bind(with: self){ owner, text in
                switch owner.info {
                case .nick:
                    let result = !text.contains(" ") && text.count > 2
                    validMessage.accept(result ? "" : "3자리 이상 공백 없이 입력해주세요.")
                    isValidResult.accept(result)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        let isValid = isValidResult
            .asDriver(onErrorJustReturn: false)
        
        return Output(isValid: isValid, validMessage: validMessage)
    }
}
