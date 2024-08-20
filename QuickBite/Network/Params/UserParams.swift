//
//  UserParams.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import Foundation
import Moya


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
    
    struct EditRequest: Codable {
        let nick: String?
        let phoneNum: String?
        let birthDay: String?
        let profile: Data?
        let profileImageName: String?
        
        func convertMultiPartFormData() -> [MultipartFormData] {
            let parameters: [String : String?] = [
                "nick": nick,
                "phoneNum": phoneNum,
                "birthDay": birthDay,
            ]
            
            var multipartFormData: [MultipartFormData] = []
            
            for (key, value) in parameters {
                if let value = value {
                    multipartFormData.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: key))
                }
            }
            
            if let profile = profile, let profileImageName = profileImageName {
                multipartFormData.append(MultipartFormData(provider: .data(profile), name: "profile", fileName: profileImageName, mimeType: "image/png"))
            }
            
            return multipartFormData
            
        }
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
    
    struct EditResponse: Codable {
        let userId: String
        let email: String
        let nick: String
        let phoneNum: String?
        let birthDay: String?
        let profileImage: String?
        let posts: [String]
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case email
            case nick
            case phoneNum
            case birthDay
            case profileImage
            case posts
        }
    }
    
    struct LoadResponse: Codable {
        let userId: String
        let email: String
        let nick: String
        let phoneNum: String?
        let birthDay: String?
        let profileImage: String?
        let posts: [String]
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case email
            case nick
            case phoneNum
            case birthDay
            case profileImage
            case posts
        }
    }
}
