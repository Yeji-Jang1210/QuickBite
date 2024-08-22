//
//  PostTableViewSectionModel.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import Foundation
import RxDataSources

struct PostTableViewSectionModel {
    var items: [Post]
    
    init(items: [Post]) {
        self.items = items
    }
}

extension PostTableViewSectionModel: SectionModelType {
    init(original: PostTableViewSectionModel, items: [Post]) {
        self = original
        self.items = items
    }
}
