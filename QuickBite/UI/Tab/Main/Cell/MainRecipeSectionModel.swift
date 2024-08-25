//
//  MainRecipeSectionModel.swift
//  QuickBite
//
//  Created by 장예지 on 8/25/24.
//

import Foundation
import RxDataSources

struct MainRecipeSectionModel {
    var items: [Recipe]
    
    init(items: [Recipe]) {
        self.items = items
    }
}

extension MainRecipeSectionModel: SectionModelType {
    init(original: MainRecipeSectionModel, items: [Recipe]) {
        self = original
        self.items = items
    }
}
