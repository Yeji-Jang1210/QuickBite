//
//  DetailPostContentVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/30/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DetailPostContentVM: BaseVM, BaseVMProvider{
    struct Input {
        let expandableButtonTap: ControlEvent<Void>
        let creatorButtonTap: ControlEvent<Void>
        let pageContentOffset: ControlProperty<CGPoint>
        let pageValueChanged: ControlEvent<()>
    }
    
    struct Output {
        let expandableButtonIsSelected: BehaviorRelay<Bool>
        let descriptionNumberOfLines: Driver<Int>
        
        let titleText: Driver<String>
        let descriptionText: Driver<String>
        let creatorButtonTap: Driver<String>
        let creatorProfilePath: Driver<String?>
        let creatorNicknameText: Driver<String>
        let timeText: Driver<String>
        let servingsText: Driver<String>
        let bookmarkText: Driver<String>
        let ingredients: Driver<[Ingredient]>
        let sources: Driver<[Source]>
        let stepDataSource: Driver<[DetailSectionModel]>
        let steps: Driver<[Step]>
        
        let pageContentOffset: ControlProperty<CGPoint>
        let pageValueChanged: ControlEvent<()>
    }
    
    private var post = BehaviorRelay<Post?>(value: nil)
    
    convenience init(post: Post){
        self.init()
        self.post.accept(post)
    }
    
    func transform(input: Input) -> Output {
        let isExpandable = BehaviorRelay<Bool>(value: true)
        let post = post.compactMap{ $0 }
        
        input.expandableButtonTap
            .bind{
                isExpandable.accept(!isExpandable.value)
            }
            .disposed(by: disposeBag)
        
        let descriptionNumberOfLines = isExpandable
            .map { $0 ? 2 : 0 }
            .asDriver(onErrorJustReturn: 2)
        
        let titleText = post.map { $0.title }.asDriver(onErrorJustReturn: "")
        let description = post.map { $0.content.description }.compactMap{ $0 }.asDriver(onErrorJustReturn: "")
        let creatorProfilePath = post.map { $0.creator.profileImage }.asDriver(onErrorJustReturn: nil)
        let creatorNickname = post.map { $0.creator.nick }.asDriver(onErrorJustReturn: "")
        let timeText = post.map { "\($0.content.time)분" }.asDriver(onErrorJustReturn: "")
        let servingsText = post.map { "\($0.content.servings)인분" }.asDriver(onErrorJustReturn: "")
        let ingredients = post.map { $0.content.ingredients }.compactMap{$0}.asDriver(onErrorJustReturn: [])
        let sources = post.map { $0.content.sources }.compactMap{$0}.asDriver(onErrorJustReturn: [])
        
        //detailVC에서 +1 / -1 신호 받기
        let bookmarkText = post.map { $0.likes.count.formatted() }
            .asDriver(onErrorJustReturn: "0")
        
        //이미지 파일 어떻게 넘겨줄지 생각하기
        let stepDataSource = post
            .map{ post in
                var detailSteps: [DetailStep] = []
                
                for (index, step) in post.content.steps.enumerated() {
                    detailSteps.append(DetailStep(step: step, filePath: post.files[index]))
                }
                
                return detailSteps
            }
            .map{ [DetailSectionModel(items: $0)]  }
            .asDriver(onErrorJustReturn: [])
        
        let steps = post.map{ $0.content.steps }.asDriver(onErrorJustReturn: [])
        
        let creatorButtonTap = input.creatorButtonTap
            .withLatestFrom(post)
            .map { $0.creator.user_id }
            .asDriver(onErrorJustReturn: "")
        
        return Output(expandableButtonIsSelected: isExpandable,
                      descriptionNumberOfLines: descriptionNumberOfLines,
                      titleText: titleText,
                      descriptionText: description,
                      creatorButtonTap: creatorButtonTap,
                      creatorProfilePath: creatorProfilePath,
                      creatorNicknameText: creatorNickname,
                      timeText: timeText,
                      servingsText: servingsText,
                      bookmarkText: bookmarkText,
                      ingredients: ingredients,
                      sources: sources,
                      stepDataSource: stepDataSource,
                      steps: steps,
                      pageContentOffset: input.pageContentOffset,
                      pageValueChanged: input.pageValueChanged)
    }
}
