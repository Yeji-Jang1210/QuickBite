//
//  StepSectionModel.swift
//  QuickBite
//
//  Created by 장예지 on 8/26/24.
//

import Foundation
import RxDataSources

struct StepSectionModel {
    var items: [Step?]
    
    init(items: [Step?]) {
        self.items = items
    }
}

extension StepSectionModel: SectionModelType {
    init(original: StepSectionModel, items: [Step?]) {
        self = original
        self.items = items
    }
}
