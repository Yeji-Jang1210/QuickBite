//
//  BaseCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit
import RxSwift

class BaseCollectionViewCell: UICollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinitialized")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
