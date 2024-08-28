//
//  UserDefaultsManager.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import Foundation

final class UserDefaultsManager {
    
    private enum UserDefaultsKey: String {
        case access
        case refresh
        case userId
    }
    
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    var token: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKey.access.rawValue) ?? ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.access.rawValue)
        }
    }
    
    var refreshToken: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKey.refresh.rawValue) ?? ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.refresh.rawValue)
        }
    }
    
    var userId: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaultsKey.userId.rawValue) ?? ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.userId.rawValue)
        }
    }
    
    func setUserDetauls(_ result: Userparams.LoginResponse){
        userId = result.userId
        token = result.accessToken
        refreshToken = result.refreshToken
    }
    
    func reset(){
        token = ""
        refreshToken = ""
        userId = ""
    }
}
