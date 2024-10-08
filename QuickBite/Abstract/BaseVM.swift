//
//  BaseVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import Foundation
import RxSwift

protocol BaseVMProvider {
    associatedtype Input
    
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class BaseVM {
    
    var disposeBag = DisposeBag()
    
    init(){
        bind()
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinitialized")
    }
    
    func bind(){ }
}
