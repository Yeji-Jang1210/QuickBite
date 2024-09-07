//
//  VerticalLabels.swift
//  QuickBite
//
//  Created by 장예지 on 9/7/24.
//

import UIKit
import SnapKit
import RxSwift

final class VerticalLabels: UIView {
    let titleLabel = {
        let object = UILabel()
        object.textAlignment = .center
        object.textColor = .darkGray
        object.font = Font.semiBold(.smallLarge)
        return object
    }()
    
    let contentLabel = {
        let object = UILabel()
        object.textAlignment = .center
        object.textColor = .darkGray
        object.font = Font.boldFont(.medium)
        return object
    }()
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .vertical
        object.spacing = 4
        [titleLabel, contentLabel].map { object.addArrangedSubview($0)}
        return object
    }()
    
    var text: Binder<String?> {
        get {
            return contentLabel.rx.text
        }
    }
    
    var size: CGFloat = 44
    
    init(title: String){
        super.init(frame: .zero)
        titleLabel.text = title
        configureUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    func configureUI(){
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

