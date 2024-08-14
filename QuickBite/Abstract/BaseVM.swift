//
//  BaseVM.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import Foundation
import RxSwift

class BaseVM {
    
    let disposeBag = DisposeBag()
    
    init(){
        bind()
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinitialized")
    }
    
    func bind(){ }
}
