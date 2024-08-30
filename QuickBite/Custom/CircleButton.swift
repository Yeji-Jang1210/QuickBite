//
//  CircleButton.swift
//  QuickBite
//
//  Created by 장예지 on 8/29/24.
//

import UIKit

final class CircleButton: UIButton {
    
    init(size: CGFloat){
        super.init(frame: .zero)
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
