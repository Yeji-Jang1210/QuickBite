//
//  VerticalImageLabel.swift
//  QuickBite
//
//  Created by 장예지 on 8/30/24.
//

import UIKit
import SnapKit
import RxSwift

final class VerticalImageLabel: UIView {
    private let imageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.image = ImageAssets.timer
        object.tintColor = .darkGray
        return object
    }()
    
    let label = {
        let object = UILabel()
        object.textAlignment = .center
        object.textColor = .darkGray
        object.font = Font.semiBold(.smallLarge)
        return object
    }()
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 4
        [imageView, label].map { object.addArrangedSubview($0)}
        return object
    }()
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var text: Binder<String?> {
        get {
            return label.rx.text
        }
    }
    
    var size: CGFloat = 44
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

