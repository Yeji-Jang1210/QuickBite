//
//  RecipesCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/31/24.
//

import UIKit
import SnapKit
import Kingfisher

final class RecipesCollectionViewCell: BaseCollectionViewCell {
    let imageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFill
        object.clipsToBounds = true
        object.layer.cornerRadius = 8
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
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bookmarkBackView.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(imageView).inset(12)
        }
        
        bookmarkLabelView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    func setImage(_ path: String){
        if let url = URL(string: path){
            KingfisherManager.shared.defaultOptions = [.requestModifier(TokenPlugin(token: UserDefaultsManager.shared.token))]
            imageView.kf.setImage(with: url)
        }
    }
    
    func setCount(_ count: Int){
        bookmarkLabelView.text = count.formatted()
    }
}
