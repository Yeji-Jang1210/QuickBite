//
//  RecipeIngredientView.swift
//  QuickBite
//
//  Created by 장예지 on 8/26/24.
//

import UIKit
import SnapKit

final class RecipeIngredientView: UIView {
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.spacing = 8
        [titleLabel, ratioLabel].map { object.addArrangedSubview($0)}
        return object
    }()
    
    private let titleLabel = {
        let object = UILabel()
        object.setContentHuggingPriority(.defaultLow, for: .horizontal)
        object.font = Font.semiBold(.small)
        return object
    }()
    
    private let ratioLabel = {
        let object = UILabel()
        object.font = Font.regular(.small)
        return object
    }()
    
    let deleteButton = {
        let object = UIButton()
        object.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        object.tintColor = .darkGray
        return object
    }()

    init<T: BaseRecipeIngredient>(_ ingredient: T) {
        super.init(frame: .zero)
        addSubview(stackView)
        addSubview(deleteButton)
        
        snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(12)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.leading.equalTo(stackView.snp.trailing).offset(12)
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.text = ingredient.name
        ratioLabel.text = ingredient.ratio
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class AddRecipeIngredientView: UIView {
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.spacing = 8
        [titleTextField, ratioTextField].map { object.addArrangedSubview($0)}
        return object
    }()
    
    let titleTextField = {
       let object = BaseTextField()
        object.imageIsHidden = true
        object.placeholder = "예) 김치"
        return object
    }()
    
    let ratioTextField = {
       let object = BaseTextField()
        object.imageIsHidden = true
        object.placeholder = "예) 200g"
        return object
    }()
    
    let addButton = {
        let object = UIButton()
        object.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        object.tintColor = .darkGray
        return object
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        addSubview(addButton)
        
        snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
        }
        
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.leading.equalTo(stackView.snp.trailing).offset(12)
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
