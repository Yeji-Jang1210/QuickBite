//
//  PostCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import UIKit
import SnapKit
import Kingfisher

final class PostCollectionViewCell: BaseCollectionViewCell {
    let postImageView = {
        let object = UIImageView()
        object.backgroundColor = .systemGray4
        object.contentMode = .scaleAspectFill
        object.clipsToBounds = true
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
    
    func setImage(_ path: String){
        KingfisherManager.shared.defaultOptions = [.requestModifier(TokenPlugin(token: UserDefaultsManager.shared.token))]
        let urlString = "\(APIInfo.baseURL)/v1/\(path)"
        guard let url = URL(string: urlString) else { return }
        postImageView.kf.setImage(with: url)
    }
}


