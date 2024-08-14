//
//  Cell+Extension.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
