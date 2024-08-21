//
//  ProfileSettingSectionModel.swift
//  QuickBite
//
//  Created by 장예지 on 8/21/24.
//

import Foundation
import RxDataSources

struct ProfileSettingSectionModel {
    var header: String
    var items: [SettingInfo]
    
    init(header: String, items: [SettingInfo]) {
        self.header = header
        self.items = items
    }
}

extension ProfileSettingSectionModel: SectionModelType {
    init(original: ProfileSettingSectionModel, items: [SettingInfo]) {
        self = original
        self.items = items
    }
}
