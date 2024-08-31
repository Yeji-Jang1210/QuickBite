//
//  StepCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/26/24.
//

import UIKit
import SnapKit
import Kingfisher

final class StepCollectionViewCell: BaseCollectionViewCell {
    let imageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFill
        object.clipsToBounds = true
        object.layer.cornerRadius = 8
        object.backgroundColor = .systemGray6
        return object
    }()
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.spacing = 8
        [stepLevelLabel, stepTextLabel].map { object.addArrangedSubview($0)}
        return object
    }()
    
    let stepLevelLabel = {
        let object = UILabel()
        object.textAlignment = .left
        object.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        object.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        object.textColor = Color.primaryColor
        object.font = .systemFont(ofSize: 16, weight: .heavy)
        return object
    }()
    
    //max: 15
    let stepTextLabel = {
        let object = UILabel()
        object.textAlignment = .left
        object.setContentHuggingPriority(.defaultLow, for: .horizontal)
        object.font = Font.semiBold(.smallLarge)
        object.textColor = Color.primaryColor
        return object
    }()
    
    //max: 25
    let descriptionLabel = {
        let object = UILabel()
        object.textColor = .darkGray
        object.font = Font.regular(.small)
        return object
    }()
    
    let addButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.attributedTitle = AttributedString("화면을 눌러 단계를 등록하세요!", attributes: AttributeContainer([.font: Font.semiBold(.small)]))
        configuration.image = UIImage(systemName: "plus.viewfinder")
        configuration.baseForegroundColor = .darkGray
        configuration.titlePadding = 10
        configuration.imagePadding = 10
        configuration.imagePlacement = .top
        configuration.background.backgroundColor = .clear
        
        let object = UIButton()
        object.configuration = configuration
        object.isEnabled = false
        return object
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(stackView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(addButton)
        
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().inset(12)
            make.bottom.equalTo(stackView.snp.top).offset(-12)
        }
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(imageView).inset(8)
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-8)
            make.height.equalTo(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(stackView)
            make.bottom.equalToSuperview().inset(12)
            make.height.equalTo(20)
        }
        
        addButton.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func setData(index: Int, _ data: Step?){
        stepLevelLabel.text = "STEP \(index+1)"
        guard let step = data else {
            addButton.isHidden = false
            stepTextLabel.text = "제목을 입력해 주세요."
            descriptionLabel.text = "단계별 설명을 입력해주세요."
            return
        }
        
        if let image = step.imageData?.image {
            imageView.image = UIImage(data: image)
        }
        
        stepTextLabel.text = step.title
        descriptionLabel.text = step.description
        addButton.isHidden = true
    }
    
    func setDetailPostData(index: Int, _ data: DetailStep?){
        stepLevelLabel.text = "STEP \(index+1)"
        guard let data = data else {
            addButton.isHidden = false
            stepTextLabel.text = "제목을 입력해 주세요."
            descriptionLabel.text = "단계별 설명을 입력해주세요."
            return
        }
        
        if let path = data.filePath, let url = URL(string: "\(APIInfo.baseURL)/v1/\(path)"){
            KingfisherManager.shared.defaultOptions = [.requestModifier(TokenPlugin(token: UserDefaultsManager.shared.token))]
            let processor = DownsamplingImageProcessor(size: imageView.frame.size)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url,
                                  placeholder: nil,
                                  options: [.transition(.none), .forceTransition, .processor(processor)],
                                  completionHandler: nil)
        }
        
        stepTextLabel.text = data.step.title
        descriptionLabel.text = data.step.description
        addButton.isHidden = true
    }
}
