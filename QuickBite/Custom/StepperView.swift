//
//  StepperView.swift
//  QuickBite
//
//  Created by 장예지 on 8/27/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class StepperView: UIView {
    private let minusButton = {
        let object = UIButton()
        object.setImage(UIImage(systemName: "minus"), for: .normal)
        object.tintColor = .darkGray
        return object
    }()
    
    private let plusButton = {
        let object = UIButton()
        object.setImage(UIImage(systemName: "plus"), for: .normal)
        object.tintColor = .darkGray
        return object
    }()
    
    private let stepperValueLabel = {
        let object = UILabel()
        object.font = Font.semiBold(.medium)
        return object
    }()
    
    var value = BehaviorRelay(value: 1)
    
    var minimumValue = 1
    var maximumValue = 10
    
    var detailText: String = ""
    
    private let disposeBag = DisposeBag()
    
    init(detailText: String){
        super.init(frame: .zero)
        self.detailText = detailText
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI(){
        addSubview(minusButton)
        addSubview(stepperValueLabel)
        addSubview(plusButton)
        
        snp.makeConstraints { make in
            make.height.equalTo(stepperValueLabel.snp.height)
        }
        
        minusButton.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.verticalEdges.leading.equalToSuperview()
        }
        
        stepperValueLabel.snp.makeConstraints { make in
            make.verticalEdges.centerX.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints { make in
            make.size.equalTo(minusButton.snp.size)
            make.verticalEdges.trailing.equalToSuperview()
        }
    }
    
    func bind(){
        minusButton.rx.tap
            .bind(with: self){ owner, _ in
                let current = owner.value.value
                
                if current > owner.minimumValue {
                    owner.value.accept(current - 1)
                }
                
            }
            .disposed(by: disposeBag)
        
        plusButton.rx.tap
            .bind(with: self){ owner, _ in
                let current = owner.value.value
                
                if current < owner.maximumValue {
                    owner.value.accept(current + 1)
                }
            }
            .disposed(by: disposeBag)
        
        value
            .map { [weak self] value in
                guard let self else { return "" }
                
                return "\(value)\(detailText)"
            }
            .bind(to: stepperValueLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}
