//
//  SignInError.swift
//  QuickBite
//
//  Created by 장예지 on 8/18/24.
//

import Foundation

enum LoginError: Int {
    case accountCheckRequired = 401
    
    var description: String {
        switch self {
        case .accountCheckRequired:
            return "계정을 확인해 주세요."
        }
    }
}
