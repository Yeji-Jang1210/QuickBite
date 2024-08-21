//
//  ProfileSettingTableViewCell.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import UIKit

final class ProfileSettingTableViewCell: BaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        textLabel?.font = Font.regular(.smallLarge)
        detailTextLabel?.font = Font.boldFont(.medium)
    }
}
