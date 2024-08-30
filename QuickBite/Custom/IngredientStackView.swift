//
//  IngredientStackView.swift
//  QuickBite
//
//  Created by 장예지 on 8/30/24.
//

import UIKit
import SnapKit
import RxSwift

final class IngredientStackView: UIView {
    
    private let dotImageView = {
        let object = UIImageView()
        object.image = UIImage(systemName: "circle.fill")
        object.setContentHuggingPriority(.init(1000), for: .horizontal)
        object.contentMode = .scaleAspectFit
        object.tintColor = .darkGray
        object.clipsToBounds = true
        return object
    }()
    
    private let nameLabel = {
        let object = UILabel()
        object.textAlignment = .left
        object.textColor = .darkGray
        object.font = Font.semiBold(.smallLarge)
        return object
    }()
    
    private let ratioLabel = {
        let object = UILabel()
        object.textAlignment = .right
        object.textColor = .darkGray
        object.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        object.font = Font.semiBold(.smallLarge)
        return object
    }()
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.alignment = .center
        object.spacing = 8
        [dotImageView, nameLabel, ratioLabel].map { object.addArrangedSubview($0)}
        return object
    }()
    
    init(name: String, ratio: String){
        super.init(frame: .zero)
        nameLabel.text = name
        ratioLabel.text = ratio
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(nameLabel.snp.height)
        }
        
        dotImageView.snp.makeConstraints { make in
            make.size.equalTo(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
