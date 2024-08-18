//
//  UserParams.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import Foundation


class Userparams {
    struct JoinRequest: Codable {
        let email: String
        let password: String
        let nick: String
        let phoneNum: String?
        let birthDay: String?
    }
    
    struct ValidationEmailRequest: Codable {
        let email: String
    }
    
    struct LoginRequest: Codable {
        let email: String
        let password: String
    }
    
    struct TokenRequest: Codable {
        var refreshToken: String
        var token: String
    }
    
    struct LoginResponse: Codable {
        let email: String
        let userId: String
        let profileImage: String?
        let accessToken: String
        let refreshToken: String
        
        enum CodingKeys: String, CodingKey {
            case email
            case userId = "user_id"
            case profileImage
            case accessToken
            case refreshToken
        }
    }
    
    struct TokenResponse: Codable {
        let accessToken: String
    }
    
    struct ValidationEmailResponse: Codable {
        let email: String
    }
    
    struct StatusMessageResponse: Codable {
        let message: String
    }
    
    struct SignupResponse: Codable {
        let userId: String
        let email: String
        let nick: String
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case email
            case nick
        }
    }
}
