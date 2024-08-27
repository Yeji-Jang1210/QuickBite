//
//  BlockTextView.swift
//  QuickBite
//
//  Created by 장예지 on 8/26/24.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class BlockTextView: UIView, UITextViewDelegate {
    
    let textView = {
        let object = UITextView()
        object.font = Font.regular(.small)
        object.isScrollEnabled = false
        object.backgroundColor = .clear
        return object
    }()
    
    let countLabel = {
        let object = UILabel()
        object.textAlignment = .right
        object.font = Font.regular(.small)
        return object
    }()
    
    var minimumHeight: CGFloat
    var maxCount: Int
    
    private let disposeBag = DisposeBag()
    
    init(minimumHeight: CGFloat = 60, maxCount: Int = 10){
        self.minimumHeight = minimumHeight
        self.maxCount = maxCount
        super.init(frame: .zero)
        setLayout()
    }
    
    func setLayout(){
        addSubview(textView)
        addSubview(countLabel)
        
        snp.makeConstraints { make in
            make.height.lessThanOrEqualTo(minimumHeight)
        }
        
        textView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview().inset(8)
            make.trailing.equalTo(countLabel.snp.leading).offset(-8)
        }
        
        countLabel.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(12)
            make.width.equalTo(56)
        }
        
        backgroundColor = .systemGray6
        clipsToBounds = true
        layer.cornerRadius = 8
        
        textView.font = Font.regular(.small)
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(){
        textView.rx.didChange
            .bind(with: self) { owner, _ in
                let size = CGSize(width: owner.textView.frame.width, height: .infinity)
                let estimatedSize = owner.textView.sizeThatFits(size)
                let isMaxHeight = estimatedSize.height >= self.minimumHeight
                guard isMaxHeight != owner.textView.isScrollEnabled else { return }
                owner.textView.isScrollEnabled = isMaxHeight
                owner.textView.reloadInputViews()
                owner.textView.setNeedsUpdateConstraints()
            }
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .map { String($0.prefix(self.maxCount)) }
            .bind(to: textView.rx.text)
            .disposed(by: disposeBag)
        
        textView.rx.text.orEmpty
            .map { "\($0.count)/\(self.maxCount)" }
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}
