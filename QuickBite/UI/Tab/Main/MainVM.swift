//
//  MainVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import UIKit
import RxSwift
import RxCocoa

// 더미 Recipe 데이터 (한글)
let recipes = [
    Recipe(
        title: "김치찌개",
        description: "한국 전통 김치찌개 레시피.",
        steps: [
            Step(title: "1단계", description: "김치를 잘게 썰어 준비한다."),
            Step(title: "2단계", description: "돼지고기를 팬에 볶다가 김치를 넣고 더 볶는다."),
            Step(title: "3단계", description: "물과 멸치 육수를 넣고 끓인다."),
            Step(title: "4단계", description: "간을 맞추기 위해 고추장과 된장을 추가한다."),
            Step(title: "5단계", description: "두부와 대파를 넣고 마지막으로 끓인다.")
        ],
        ingredients: [
            Ingredient(name: "김치", ratio: "200g"),
            Ingredient(name: "돼지고기", ratio: "150g"),
            Ingredient(name: "두부", ratio: "1/2모"),
            Ingredient(name: "대파", ratio: "1대")
        ],
        sources: [
            Source(name: "고추장", ratio: "1큰술"),
            Source(name: "멸치 육수", ratio: "500ml")
        ],
        time: "30분",
        servings: 3
    ),
    Recipe(
        title: "비빔밥",
        description: "다양한 나물과 고기를 넣은 비빔밥 레시피.",
        steps: [
            Step(title: "1단계", description: "각종 나물을 준비하고 데친다."),
            Step(title: "2단계", description: "소고기를 양념하여 볶는다."),
            Step(title: "3단계", description: "밥을 그릇에 담고 나물과 고기를 올린다."),
            Step(title: "4단계", description: "고추장과 참기름을 추가한다."),
            Step(title: "5단계", description: "계란 후라이를 올려서 비벼 먹는다.")
        ],
        ingredients: [
            Ingredient(name: "밥", ratio: "1공기"),
            Ingredient(name: "소고기", ratio: "100g"),
            Ingredient(name: "시금치", ratio: "50g"),
            Ingredient(name: "콩나물", ratio: "50g"),
            Ingredient(name: "고추장", ratio: "2큰술")
        ],
        sources: [
            Source(name: "참기름", ratio: "1큰술")
        ],
        time: "20분",
        servings: 2
    ),
    Recipe(
        title: "된장국",
        description: "구수한 된장국 레시피.",
        steps: [
            Step(title: "1단계", description: "된장을 물에 풀어 끓인다."),
            Step(title: "2단계", description: "애호박과 두부를 썰어 넣는다."),
            Step(title: "3단계", description: "다진 마늘과 고춧가루를 추가한다."),
            Step(title: "4단계", description: "끓을 때 대파를 넣고 한소끔 더 끓인다."),
            Step(title: "5단계", description: "간을 보고 부족하면 된장을 더 넣는다.")
        ],
        ingredients: [
            Ingredient(name: "된장", ratio: "2큰술"),
            Ingredient(name: "애호박", ratio: "1/2개"),
            Ingredient(name: "두부", ratio: "1/3모"),
            Ingredient(name: "대파", ratio: "1대"),
            Ingredient(name: "다진 마늘", ratio: "1작은술")
        ],
        sources: [
            Source(name: "물", ratio: "600ml")
        ],
        time: "15분",
        servings: 4
    ),
    Recipe(
        title: "불고기",
        description: "달콤 짭조름한 불고기 레시피.",
        steps: [
            Step(title: "1단계", description: "소고기를 얇게 썬다."),
            Step(title: "2단계", description: "양념장을 만들어 고기를 재운다."),
            Step(title: "3단계", description: "양파와 당근을 채 썬다."),
            Step(title: "4단계", description: "재워둔 고기를 팬에 볶다가 야채를 넣고 익힌다."),
            Step(title: "5단계", description: "불고기를 접시에 담아낸다.")
        ],
        ingredients: [
            Ingredient(name: "소고기", ratio: "300g"),
            Ingredient(name: "양파", ratio: "1개"),
            Ingredient(name: "당근", ratio: "1/2개"),
            Ingredient(name: "간장", ratio: "3큰술"),
            Ingredient(name: "설탕", ratio: "1큰술")
        ],
        sources: [
            Source(name: "참기름", ratio: "1큰술")
        ],
        time: "25분",
        servings: 3
    ),
    Recipe(
        title: "잡채",
        description: "쫄깃한 당면과 다양한 야채가 어우러진 잡채 레시피.",
        steps: [
            Step(title: "1단계", description: "당면을 삶아 찬물에 헹군다."),
            Step(title: "2단계", description: "고기와 야채를 채 썰어 준비한다."),
            Step(title: "3단계", description: "고기를 볶다가 야채를 넣고 같이 볶는다."),
            Step(title: "4단계", description: "당면을 넣고 간장과 설탕으로 간을 맞춘다."),
            Step(title: "5단계", description: "참기름을 넣고 섞어 접시에 담는다.")
        ],
        ingredients: [
            Ingredient(name: "당면", ratio: "150g"),
            Ingredient(name: "소고기", ratio: "100g"),
            Ingredient(name: "시금치", ratio: "50g"),
            Ingredient(name: "당근", ratio: "1/2개"),
            Ingredient(name: "간장", ratio: "3큰술")
        ],
        sources: [
            Source(name: "참기름", ratio: "1큰술")
        ],
        time: "30분",
        servings: 4
    )
]


final class MainVM: BaseVM, BaseVMProvider {
    
    struct Input {
        let addPostButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let addPostButtonTap: ControlEvent<Void>
        let items: Driver<[MainRecipeSectionModel]>
    }
    
    func transform(input: Input) -> Output {
        
        let items = Observable.just(recipes)
            .map { [MainRecipeSectionModel(items: $0)]}
            .asDriver(onErrorJustReturn: [])
            
        
        return Output(addPostButtonTap: input.addPostButtonTap, items: items)
    }
}
