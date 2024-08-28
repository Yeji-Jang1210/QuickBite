//
//  SignInError.swift
//  QuickBite
//
//  Created by 장예지 on 8/28/24.
//

import Foundation

enum SignInError: Int {
    case notFoundRequiredValue = 400
    case notUser = 401
    
    var message: String {
        switch self {
        case .notFoundRequiredValue:
            return "필수값을 채워주세요"
        case .notUser:
            return "계정을 확인해주세요"
        }
    }
}
