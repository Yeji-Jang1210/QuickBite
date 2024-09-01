//
//  AddPostVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/26/24.
//

import Foundation
import RxSwift
import RxCocoa

final class AddPostVM: BaseVM, BaseVMProvider {
    
    private let steps = BehaviorRelay<[Step?]>(value: Array(repeating: nil, count: 1))
    private let ingredients = BehaviorRelay<[Ingredient]>(value: [])
    private let sources = BehaviorRelay<[Source]>(value: [])
    private let isLoading = PublishRelay<Bool>()
    
    struct Input {
        let titleText: ControlProperty<String>
        let descriptionText: ControlProperty<String>
        let stepItemSelected: ControlEvent<IndexPath>
        let stepModelSelected: ControlEvent<Step?>
        let ingredientsTitle: ControlProperty<String>
        let ingredientsRatio: ControlProperty<String>
        let addIngredientTap: ControlEvent<Void>
        let deleteIngredients: PublishRelay<Int>
        let sourcesTitle: ControlProperty<String>
        let sourcesRatio: ControlProperty<String>
        let addSourceTap: ControlEvent<Void>
        let servingsValue: BehaviorRelay<Int>
        let timeText: ControlProperty<String>
        let deleteSources: PublishRelay<Int>
        let appendStep: PublishRelay<(Step?, Int)>
        let saveButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let titleText: ControlProperty<String>
        let stepItems: Driver<[StepSectionModel]>
        let stepItemSelected: Driver<(Step?,IndexPath?)>
        let ingredientItems: Driver<[Ingredient]>
        let sourceItems: Driver<[Source]>
        let clearIngredientTextField: Signal<Void>
        let clearSourceTextField: Signal<Void>
        let timeText: Driver<String>
        let isAllAlowed: Driver<Bool>
        let toastMessage: Driver<String>
        let addPostSucceess: PublishRelay<Void>
        let loadAnimation: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let clearIngredientFieldsRelay = PublishRelay<Void>()
        let clearSourceFieldsRelay = PublishRelay<Void>()
        let toastMessage = PublishRelay<String>()
        let imageFileName = PublishRelay<[String]>()
        let addPost = PublishRelay<Void>()
        let addPostSucceess = PublishRelay<Void>()
        
        let stepItems = steps
            .map {[StepSectionModel(items: $0)]}
            .asDriver(onErrorJustReturn: [])
        
        let stepItemSelected = Observable
            .zip(input.stepModelSelected, input.stepItemSelected)
            .compactMap { model, index in
                return (model, index)
            }
            .asDriver(onErrorJustReturn: (nil,nil))
        
        let ingredientsItem = ingredients
            .asDriver()
        
        let newIngredient = Observable.combineLatest(input.ingredientsTitle, input.ingredientsRatio) { title, ratio -> Ingredient in
            return Ingredient(name: title, ratio: ratio)
        }
        
        input.addIngredientTap
            .withLatestFrom(newIngredient)
            .bind(with: self) { owner, value in
                var currentIngredients = owner.ingredients.value
                currentIngredients.append(value)
                owner.ingredients.accept(currentIngredients)
                clearIngredientFieldsRelay.accept(())
            }
            .disposed(by: disposeBag)
        
        
        input.deleteIngredients
            .bind(with: self){ owner, index in
                var currentIngredients = owner.ingredients.value
                currentIngredients.remove(at: index)
                owner.ingredients.accept(currentIngredients)
                clearIngredientFieldsRelay.accept(())
            }
            .disposed(by: disposeBag)
        
        let clearIngredientFields = clearIngredientFieldsRelay.asSignal()
        
        let sourcesItem = sources
            .asDriver()
        
        let newSource = Observable.combineLatest(input.sourcesTitle, input.sourcesRatio) { title, ratio -> Source in
            return Source(name: title, ratio: ratio)
        }
        
        input.addSourceTap
            .withLatestFrom(newSource)
            .bind(with: self) { owner, value in
                var currentSources = owner.sources.value
                currentSources.append(value)
                owner.sources.accept(currentSources)
                clearSourceFieldsRelay.accept(())
            }
            .disposed(by: disposeBag)
        
        input.deleteSources
            .bind(with: self){ owner, index in
                var currentSources = owner.sources.value
                currentSources.remove(at: index)
                owner.sources.accept(currentSources)
                clearSourceFieldsRelay.accept(())
            }
            .disposed(by: disposeBag)
        
        let clearSourceFields = clearSourceFieldsRelay.asSignal()
        
        input.appendStep
            .bind(with: self){ owner, result in
                var currentStep = owner.steps.value
                currentStep[result.1] = result.0
                
                if currentStep.count != 5 {
                    currentStep.append(nil)
                }
                owner.steps.accept(currentStep)
            }
            .disposed(by: disposeBag)
        
        let timeText = input.timeText
            .map {
                guard let value = Int($0) else { return "" }
                return "\(value)"
            }
            .asDriver(onErrorJustReturn: "")
        
        let isAllAlowed = Observable
            .combineLatest(input.titleText.asObservable(), steps.asObservable(), timeText.asObservable())
            .map { title, steps, time in
                return !title.isEmpty && steps.count > 1 && !time.isEmpty}
            .asDriver(onErrorJustReturn: false)
        
        input.saveButtonTap
            .debug("저장버튼")
            .withLatestFrom(steps)
            .flatMap { [weak self] steps in
                self?.isLoading.accept(true)
                
                return Observable.just(PostParams.FileUploadRequest(files: steps.compactMap{$0?.imageData}))
            }
            .flatMap {
                PostAPI.shared.networking(service: .fileUpload(param: $0), type: PostParams.FileUploadResponse.self)
            }
            .bind{ networkResult in
                switch networkResult {
                case .success(let result):
                    addPost.accept(())
                    imageFileName.accept(result.files)
                case .error(let statusCode):
                    guard let error = UploadFileError(rawValue: statusCode) else {
                        toastMessage.accept("알수없는 오류입니다.")
                        return
                    }
                    toastMessage.accept(error.message)
                }
            }
            .disposed(by: disposeBag)
        
        addPost
            .flatMap { _ -> Observable<Recipe> in
                Observable.zip(
                    input.descriptionText.asObservable(),
                    self.steps.asObservable(),
                                                       self.ingredients.asObservable(),
                                                       self.sources.asObservable(),
                                                       timeText.asObservable(),
                                                       input.servingsValue.asObservable())
                    .compactMap { description, steps, ingredients, sources, time, servings in
                        let step = steps.compactMap{ $0 }
                        
                        return Recipe(description: description, steps: step, ingredients: ingredients, sources: sources, time: time, servings: servings)
                    }
            }
            .flatMap { param -> Observable<String> in
                let encoder = JSONEncoder()
                if let jsonData = try? encoder.encode(param) {
                    if let jsonString = String(data: jsonData, encoding: .utf8){
                        return Observable.just(jsonString)
                    }
                }
                return Observable.empty()
            }
            .flatMap { jsonString in
                Observable.zip(input.titleText, imageFileName){
                    return ($0, jsonString, $1)
                }
            }
            .compactMap {
                PostParams.AddPostRequest(title: $0, content: $1, files: $2)
            }
            .flatMap {
                PostAPI.shared.networking(service: .add(param: $0), type: PostParams.AddPostResponse.self)
            }
            .bind(with: self){ owner, networkResult in
                switch networkResult {
                case .success(_):
                    owner.isLoading.accept(false)
                    toastMessage.accept("저장되었습니다.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        addPostSucceess.accept(())
                    }
                case .error(let statusCode):
                    guard let error = UploadPostError(rawValue: statusCode) else {
                        owner.isLoading.accept(false)
                        toastMessage.accept("알수없는 오류입니다.")
                        return
                    }
                    owner.isLoading.accept(false)
                    toastMessage.accept(error.message)
                }
            }
            .disposed(by: disposeBag)

        let errorMessage = toastMessage.asDriver(onErrorJustReturn: "")
        let loadAnimation = isLoading.asDriver(onErrorJustReturn: false)
        
        return Output(titleText: input.titleText,
                      stepItems: stepItems,
                      stepItemSelected: stepItemSelected,
                      ingredientItems: ingredientsItem,
                      sourceItems: sourcesItem,
                      clearIngredientTextField: clearIngredientFields,
                      clearSourceTextField: clearSourceFields,
                      timeText: timeText,
                      isAllAlowed: isAllAlowed, 
                      toastMessage: errorMessage, 
                      addPostSucceess: addPostSucceess, 
                      loadAnimation: loadAnimation)
    }
}
