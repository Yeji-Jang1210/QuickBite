//
//  PostListVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/27/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostListVM: BaseVM, BaseVMProvider {
    struct Input {
        
    }
    
    struct Output {
        let items: PublishRelay<[PostSectionModel]>
    }
    
    func transform(input: Input) -> Output {
        let items = PublishRelay<[PostSectionModel]>()
        
        return Output(items: items)
    }
}
