//
//  MealKitPaymentCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 9/1/24.
//

import UIKit
import SnapKit
import Kingfisher

final class MealKitPaymentCollectionViewCell: BaseCollectionViewCell {
    let imageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFill
        object.clipsToBounds = true
        object.layer.cornerRadius = 8
        return object
    }()
    
    private let titleLabel = {
        let object = UILabel()
        object.text = "[밀키트] 맛있는 부대찌개"
        object.numberOfLines = 2
        object.font = Font.semiBold(.small)
        object.textColor = Color.primaryColor
        return object
    }()
    
    private let priceLabel = {
        let object = UILabel()
        object.text = "100원"
        object.font = Font.regular(.small)
        return object
    }()
    
    let paymentButton = {
        let object = BaseButton()
        object.title = "밀키트 구매하기"
        object.font = Font.semiBold(.small)
        return object
    }()
    
    private lazy var bookmarkBackView = {
        let object = UIView()
        object.backgroundColor = .gray.withAlphaComponent(0.6)
        object.addSubview(bookmarkLabelView)
        object.clipsToBounds = true
        object.layer.cornerRadius = 8
        return object
    }()
    
    let bookmarkLabelView = {
       let object = IconLabelView(image: ImageAssets.heart)
        object.tintColor = .white
        return object
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(bookmarkBackView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(paymentButton)
        
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
        
        bookmarkBackView.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(imageView).inset(12)
        }
        
        bookmarkLabelView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
        }
        
        paymentButton.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(24)
        }
        
    }
    
    func setData(_ post: Post){
        if let path = post.files.last, let url = URL(string:  "\(APIInfo.baseURL)/v1/\(path)") {
            KingfisherManager.shared.defaultOptions = [.requestModifier(TokenPlugin(token: UserDefaultsManager.shared.token))]
            imageView.kf.setImage(with: url)
        }
        
        bookmarkLabelView.text = post.likes.count.formatted()
        titleLabel.text = post.title
    }
}
