//
//  Recipe.swift
//  QuickBite
//
//  Created by 장예지 on 8/25/24.
//

import Foundation


//post - content1 에 저장되는 구조체
struct Recipe: Codable {
    let description: String?
    let steps: [Step]
    let ingredients: [Ingredient]?
    let sources: [Source]?
    let time: String
    let servings: Int
}

struct Step: Codable {
    let title: String
    let description: String?
    let imageData: ImageData?
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
    }
    
    init(imageData: ImageData? = nil, title: String, description: String?) {
        self.imageData = imageData
        self.title = title
        self.description = description
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.imageData = nil // imageData는 디코딩하지 않음
    }
}

struct ImageData: Codable {
    let image: Data
    let name: String
}

struct Ingredient: BaseRecipeIngredient, Codable {
    var name: String
    var ratio: String
}

struct Source: BaseRecipeIngredient, Codable {
    var name: String
    var ratio: String
}

protocol BaseRecipeIngredient {
    var name: String { get set }
    var ratio: String { get set }
}
