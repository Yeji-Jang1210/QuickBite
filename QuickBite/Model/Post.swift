//
//  Post.swift
//  QuickBite
//
//  Created by 장예지 on 8/22/24.
//

import Foundation

struct Post: Codable {
    let post_id: String
    let product_id: String
    let title: String
    let content: Recipe
    let createdAt: String
    let creator: Creator
    let files: [String]
    var likes: [String]
}
