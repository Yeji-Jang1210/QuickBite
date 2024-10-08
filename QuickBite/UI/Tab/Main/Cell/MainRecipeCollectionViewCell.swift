//
//  MainRecipeCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/25/24.
//

import UIKit
import SnapKit
import Kingfisher

import RxSwift
import RxCocoa


final class MainRecipeCollectionViewCell: BaseCollectionViewCell {
    
    private let baseView = UIView()
    
    private let imageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFill
        object.backgroundColor = .systemGray6
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
        object.font = Font.regular(.smallLarge)
        return object
    }()
    
    let bookmarkButton = {
        let object = UIButton()
        object.setBackgroundImage(ImageAssets.bookmark, for: .normal)
        object.setBackgroundImage(ImageAssets.bookmarkFill, for: .selected)
        object.isSelected = false
        object.tintColor = Color.primaryColor
        return object
    }()
    
    private let servingsView = IconLabelView(image: ImageAssets.servings)
    private let timeView = IconLabelView(image: ImageAssets.timer)
    private let bookmarkCountView = IconLabelView(image: ImageAssets.heart)
    
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
    
    let bookmarkButtonTap = PublishRelay<Post>()
    let bookmarkIsSelected = PublishRelay<Bool>()
    
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
        stackView.addArrangedSubview(timeView)
        stackView.addArrangedSubview(bookmarkCountView)
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
            make.trailing.equalToSuperview().inset(12)
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
    
    func setData(_ post: Post){
        if let thumbnailFilePath = post.files.last {
            guard let url = URL(string: "\(APIInfo.baseURL)/v1/\(thumbnailFilePath)") else { return }
            KingfisherManager.shared.defaultOptions = [.requestModifier(TokenPlugin(token: UserDefaultsManager.shared.token))]
            let processor = DownsamplingImageProcessor(size: imageView.frame.size)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url,
                                  placeholder: nil,
                                  options: [.transition(.none), .forceTransition, .processor(processor)],
                                  completionHandler: nil)
            
            
        }
        
        bookmarkButton.isSelected = post.likes.contains(UserDefaultsManager.shared.userId)
        
        titleLabel.text = post.title
        servingsView.text = "\(post.content.servings)인분"
        timeView.text = "\(post.content.time)분"
        bookmarkCountView.text = post.likes.count.formatted()
        
    }
}
