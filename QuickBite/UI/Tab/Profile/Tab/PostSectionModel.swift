//
//  PostSectionModel.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import Foundation
import RxDataSources

struct PostSectionModel {
    
    typealias Item = Post
    
    var items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
}

extension PostSectionModel: SectionModelType {
    init(original: PostSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

