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
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    var title: String = "" {
        didSet {
            self.titleLabel?.font = Font.regular(.medium)
            self.setTitle(title, for: .normal)
        }
    }
    
    var font: UIFont = Font.regular(.medium) {
        didSet {
            self.titleLabel?.font = font
        }
    }

    init() {
        super.init(frame: .zero)
        self.backgroundColor = Color.primaryColor
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
