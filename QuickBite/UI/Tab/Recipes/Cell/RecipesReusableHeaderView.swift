//
//  RecipesReusableHeaderView.swift
//  QuickBite
//
//  Created by 장예지 on 9/2/24.
//

import UIKit
import SnapKit

final class RecipesReusableHeaderView: UICollectionReusableView {
    static let identifier = String(describing: RecipesReusableHeaderView.self)
    
    private var titleLabel = {
        let object = UILabel()
        object.text = "전체 레시피 보기"
        object.font = Font.semiBold(.large)
        object.textAlignment = .center
        object.textColor = Color.primaryColor
        return object
    }()
    
    private var descriptionLabel = {
        let object = UILabel()
        object.text = "마음에 드는 메뉴를 골라봐요!"
        object.textAlignment = .center
        object.font = Font.regular(.small)
        return object
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(titleLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
