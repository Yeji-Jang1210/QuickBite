//
//  PostCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import UIKit
import SnapKit

final class PostCollectionViewCell: BaseCollectionViewCell {
    let postImageView = {
        let object = UIImageView()
        object.backgroundColor = .systemGray4
        object.contentMode = .scaleAspectFill
        return object
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        contentView.addSubview(postImageView)
    }
    
    override func configureLayout() {
        super.configureLayout()
        postImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

