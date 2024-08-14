//
//  BaseButton.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit
import SnapKit

final class BaseButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? Color.primaryColor : UIColor.lightGray
        }
    }

    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
