//
//  BaseTextField.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BaseTextField: UIView {
    
    private let textFieldImage = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFit
        object.tintColor = .lightGray
        return object
    }()
    
    lazy var textField = {
        let object = UITextField()
        return object
    }()
    
    private lazy var stackView = {
        let object = UIStackView()
        object.axis = .horizontal
        object.alignment = .center
        object.spacing = 12
        [textFieldImage, textField].map { object.addArrangedSubview($0) }
        return object
    }()
    
    private let validationLabel = {
        let object = UILabel()
        object.font = Font.regular(.small)
        object.textAlignment = .right
        return object
    }()
    
    var imageIsHidden: Bool = false {
        didSet {
            textFieldImage.isHidden = imageIsHidden
        }
    }
    
    var image: UIImage? {
        didSet {
            textFieldImage.image = image
        }
    }
    
    private let separateLine = {
        let object = UIView()
        object.backgroundColor = .lightGray
        return object
    }()
    
    var text: ControlProperty<String?> {
        return textField.rx.text
    }
    
    var textColor: Binder<UIColor?> {
        return textField.rx.textColor
    }
    
    var isEditing: Binder<Bool> {
        return textField.rx.isEnabled
    }
    
    var validationStatusText: Binder<String?> {
        return validationLabel.rx.text
    }
    
    var validationStatusTextColor: Binder<UIColor> {
        return validationLabel.rx.textColor
    }
    
    var placeholder: String = "" {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.font: Font.regular(.smallLarge)])
        }
    }
    
    var isSecureTextEntry: Bool = false {
        didSet {
            textField.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    var separateLineColor: UIColor = .lightGray {
        didSet {
            separateLine.backgroundColor = separateLineColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
    }
    
    func configureHierarchy(){
        addSubview(stackView)
        addSubview(separateLine)
        addSubview(validationLabel)
    }
    
    func configureLayout(){
        textFieldImage.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(12)
        }
        
        separateLine.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.equalTo(stackView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        validationLabel.snp.makeConstraints { make in
            make.top.equalTo(separateLine.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(separateLine.snp.horizontalEdges)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
