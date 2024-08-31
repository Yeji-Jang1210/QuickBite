//
//  DetailSectionModel.swift
//  QuickBite
//
//  Created by 장예지 on 8/31/24.
//

import Foundation
import RxDataSources

struct DetailSectionModel {
    var items: [DetailStep]
    
    init(items: [DetailStep]) {
        self.items = items
    }
}

extension DetailSectionModel: SectionModelType {
    init(original: DetailSectionModel, items: [DetailStep]) {
        self = original
        self.items = items
    }
}

struct DetailStep {
    let step: Step
    let filePath: String?
}
