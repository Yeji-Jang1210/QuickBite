//
//  PostSectionModel.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import Foundation
import RxDataSources

struct PostSectionModel {
    var items: [Post]
    
    init(items: [Post]) {
        self.items = items
    }
}

extension PostSectionModel: SectionModelType {
    init(original: PostSectionModel, items: [Post]) {
        self = original
        self.items = items
    }
}

