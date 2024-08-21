//
//  TabBarCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/21/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TabBarCollectionViewCell: BaseCollectionViewCell {
    
    let iconImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.tintColor = .systemGray6
        object.image = ImageAssets.person
        return object
    }()
    
    let underLineView = {
        let object = UIView()
        object.backgroundColor = Color.primaryColor
        object.alpha = 0.0
        return object
    }()
    
    override var isSelected: Bool {
        didSet {
            iconImageView.tintColor = isSelected ? Color.primaryColor : .systemGray6
            underLineView.alpha = isSelected ? 1.0 : 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        contentView.addSubview(underLineView)
        contentView.addSubview(iconImageView)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        iconImageView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(10)
        }
        
        underLineView.snp.makeConstraints { make in
            make.height.equalTo(3.0)
            make.top.equalTo(iconImageView.snp.bottom).offset(4.0)
            make.horizontalEdges.equalToSuperview().inset(40)
            make.bottom.equalToSuperview()
        }
    }
    
    func setImage(image: UIImage?) {
        iconImageView.image = image
    }
    
    override func prepareForReuse() {
        isSelected = false
    }
}
