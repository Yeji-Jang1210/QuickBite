//
//  User.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import Foundation

struct User: Codable {
    let id: String
    let email: String
    let nick: String
    let phoneNum: String?
    let birthDay: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email
        case nick
        case phoneNum
        case birthDay
    }
}
