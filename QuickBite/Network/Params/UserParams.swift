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
        
        init(nick: String?, phoneNum: String?, birthDay: String?, profile: Data?, prorilfeImageName: String?) {
            self.nick = nick
            self.phoneNum = phoneNum
            self.birthDay = birthDay
            self.profile = profile
            self.profileImageName = prorilfeImageName
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(nick, forKey: .nick)
            try container.encode(phoneNum, forKey: .phoneNum)
            try container.encode(birthDay, forKey: .birthDay)
            try container.encode(profile, forKey: .profile)
        }
        
        enum CodingKeys: CodingKey {
            case nick
            case phoneNum
            case birthDay
            case profile
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.nick = try container.decodeIfPresent(String.self, forKey: .nick)
            self.phoneNum = try container.decodeIfPresent(String.self, forKey: .phoneNum)
            self.birthDay = try container.decodeIfPresent(String.self, forKey: .birthDay)
            self.profile = try container.decodeIfPresent(Data.self, forKey: .profile)
            self.profileImageName = nil
        }
        
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
        
        init(){
            refreshToken = UserDefaultsManager.shared.refreshToken
            token = UserDefaultsManager.shared.token
        }
    }
    
    
//MARK: - Response
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
    
    struct OtherUserResponse: Codable {
        let userId: String
        let nick: String
        let profileImage: String?
        let posts: [String]
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case nick
            case profileImage
            case posts
        }
    }
    
    struct WithDrawResponse: Codable {
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
