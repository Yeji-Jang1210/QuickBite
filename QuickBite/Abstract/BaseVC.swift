//
//  BaseVC.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

class BaseVC: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinitialized")
    }
    
    func configureHierarchy(){ }
    
    func configureLayout(){ }
    
    func configureUI(){ }
    
    func bind(){ }
    
    func showToastMsg(msg: String){
        view.hideAllToasts()
        DispatchQueue.main.async {
            self.view.makeToast(msg)
        }
    }
}
