//
//  AddStepVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/26/24.
//

import RxSwift
import RxCocoa
import UIKit

final class AddStepVM: BaseVM, BaseVMProvider {
    
    let stepImageData = BehaviorRelay<Data?>(value: nil)
    let stepImageName = BehaviorRelay<String?>(value: nil)
    
    struct Input {
        let galleryButtonTap: ControlEvent<Void>
        let titleText: ControlProperty<String>
        let descriptionText: ControlProperty<String>
        let saveButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let titleText: Driver<String>
        let descriptionText: Driver<String>
        let galleryButtonTap: ControlEvent<Void>
        let isEnableSaveButton: Driver<Bool>
        let image: Driver<Data?>
        let outputDismissView: Driver<Step?>
    }
    
    func transform(input: Input) -> Output {
        
        let titleText = input.titleText
            .map{ String($0.prefix(15)) }
            .asDriver(onErrorJustReturn: "")
        
        let descriptionText = input.descriptionText
            .map{ String($0.prefix(25)) }
            .asDriver(onErrorJustReturn: "")
        
        let isEnableSaveButton = titleText
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)
        
        let image = stepImageData
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: nil)
        
        let imageData = Observable.combineLatest(stepImageData, stepImageName)
            .compactMap { (data, name) -> ImageData? in
                guard let data = data, let name = name else {
                    return nil
                }
                return ImageData(image: data, name: name)
            }
        
        let step = input.saveButtonTap
            .withLatestFrom(Observable.combineLatest(imageData.asObservable(), input.titleText.asObservable(), input.descriptionText.asObservable()))
            .compactMap { (imageData, title, description) in
                Step(imageData: imageData, title: title, description: description)
            }
            .asDriver(onErrorJustReturn: nil)
        
        
        return Output(titleText: titleText,
                      descriptionText: descriptionText,
                      galleryButtonTap: input.galleryButtonTap,
                      isEnableSaveButton: isEnableSaveButton,
                      image: image,
                      outputDismissView: step)
    }
}
