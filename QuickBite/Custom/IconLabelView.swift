//
//  IconLabelView.swift
//  QuickBite
//
//  Created by 장예지 on 8/25/24.
//

import UIKit
import SnapKit
import RxCocoa

final class IconLabelView: UIView {
    private let imageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.tintColor = Color.primaryColor
        return object
    }()
    
    private let label = {
        let object = UILabel()
        object.font = Font.regular(.small)
        return object
    }()
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.spacing = 4
        object.alignment = .center
        [imageView, label].map { object.addArrangedSubview($0) }
        return object
    }()
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var text: String? {
        didSet{
            label.text = text
        }
    }
    
    override var tintColor: UIColor? {
        didSet {
            imageView.tintColor = tintColor
            label.textColor = tintColor
        }
    }
    
    init(image: UIImage?){
        super.init(frame: .zero)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
        
        self.tintColor = .darkGray
        self.imageView.image = image
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
