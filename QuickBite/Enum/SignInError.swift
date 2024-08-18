//
//  SignInError.swift
//  QuickBite
//
//  Created by 장예지 on 8/18/24.
//

import Foundation

enum LoginError: Int {
    case accountCheckRequired = 401
    case decodedError
    
    var description: String {
        switch self {
        case .accountCheckRequired:
            return "계정을 확인해 주세요."
        case .decodedError:
            return "로그인 정보를 불러오는데 실패했습니다."
        }
    }
}
