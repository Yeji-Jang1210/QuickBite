//
//  MainRecipeCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/25/24.
//

import UIKit
import SnapKit

final class MainRecipeCollectionViewCell: BaseCollectionViewCell {
    
    private let baseView = UIView()
    
    private let imageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFill
        object.backgroundColor = .systemGray4
        object.clipsToBounds = true
        object.layer.cornerRadius = 8
        return object
    }()
    
    private lazy var contentsView = {
        let object = UIView()
        object.backgroundColor = .white
        object.clipsToBounds = true
        return object
    }()
    
    private let titleImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.tintColor = Color.primaryColor
        object.image = ImageAssets.recipes
        return object
    }()
    
    private let titleLabel = {
        let object = UILabel()
        object.font = Font.regular(.medium)
        return object
    }()
    
    private let bookmarkButton = {
        let object = UIButton()
        object.setBackgroundImage(ImageAssets.bookmark, for: .normal)
        object.setBackgroundImage(ImageAssets.bookmarkFill, for: .selected)
        object.tintColor = Color.primaryColor
        return object
    }()
    
    private let servingsView = IconLabelView(image: ImageAssets.servings)
    private let levelView = IconLabelView(image: ImageAssets.level)
    private let timeView = IconLabelView(image: ImageAssets.timer)
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.distribution = .equalSpacing
        return object
    }()
    
    private lazy var backView = {
        let object = UIView()
        object.backgroundColor = .white
        return object
    }()
    
    var backViewisHidden: Bool = true {
        didSet {
            backView.isHidden = backViewisHidden
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        contentView.addSubview(baseView)
        
        baseView.addSubview(imageView)
        
        baseView.addSubview(backView)
        
        baseView.addSubview(contentsView)
        contentsView.addSubview(titleImageView)
        contentsView.addSubview(titleLabel)
        contentsView.addSubview(stackView)
        stackView.addArrangedSubview(servingsView)
        stackView.addArrangedSubview(levelView)
        stackView.addArrangedSubview(timeView)
        
        baseView.addSubview(bookmarkButton)
    }
    
    override func configureLayout() {
        super.configureLayout()
        baseView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
        
        backView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(imageView.snp.horizontalEdges).inset(20)
            make.height.equalTo(contentsView).multipliedBy(0.5)
            make.bottom.equalToSuperview().inset(12)
        }
        
        titleImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(12)
            make.size.equalTo(14)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleImageView)
            make.leading.equalTo(titleImageView.snp.trailing).offset(8)
        }
        
        stackView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview().inset(12)
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
        }
        
        contentsView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(imageView.snp.horizontalEdges).inset(20)
            make.bottom.equalToSuperview().inset(12)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(imageView).inset(12)
            make.size.equalTo(30)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentsView.layer.cornerRadius = 8
        
        backView.layer.cornerRadius = 8
        backView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backView.layer.shadowRadius = 5
        backView.layer.shadowOpacity = 0.4
    }
    
    func setData(_ recipe: Recipe){
        titleLabel.text = recipe.title
        servingsView.text = "\(recipe.servings)인분"
        levelView.text = recipe.level
        timeView.text = recipe.time
    }
}
