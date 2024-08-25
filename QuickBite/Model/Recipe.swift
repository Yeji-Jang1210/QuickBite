//
//  Recipe.swift
//  QuickBite
//
//  Created by 장예지 on 8/25/24.
//

import Foundation

struct Recipe: Codable {
    let title: String
    let description: String?
    let steps: [Step]
    let ingredients: [Ingredients]
    let sources: [Source]
    let time: String
    let servings: Int
    let level: String
}

struct Step: Codable {
    let title: String
    let description: String?
}

struct Ingredients: Codable {
    let name: String
    let ratio: String
}

struct Source: Codable {
    let name: String
    let ratio: String
}
