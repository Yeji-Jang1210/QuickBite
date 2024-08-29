//
//  BookmarkSectionModel.swift
//  QuickBite
//
//  Created by 장예지 on 8/29/24.
//

import Foundation
import RxDataSources

struct BookmarkSectionModel {
    typealias Item = BookmarkViewModel
    
    var items: [Item]
    
    init(items: [Item]) {
        self.items = items
    }
}

extension BookmarkSectionModel: SectionModelType {
    init(original: BookmarkSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
