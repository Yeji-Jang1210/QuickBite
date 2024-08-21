//
//  TabPageCollectionViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/21/24.
//

import UIKit
import SnapKit

class TabPageCollectionViewCell: BaseCollectionViewCell {
    
    let backView = UIView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureHierarchy() {
        super.configureHierarchy()
        
        contentView.addSubview(backView)
        contentView.addSubview(label)
    }
    
    override func configureLayout() {
        super.configureLayout()
        
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setTitle(title: String){
        backView.backgroundColor = [.systemOrange, .systemPurple, .systemCyan, .systemMint, .systemBrown, .systemYellow].randomElement()
        label.text = title
    }
}
