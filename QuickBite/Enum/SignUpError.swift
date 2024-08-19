//
//  SignUpError.swift
//  QuickBite
//
//  Created by 장예지 on 8/19/24.
//

import Foundation

enum SignUpError: Int {
    case registeredUser = 409
    case unknownError
    case missingRequiredField = 400
    
    var message: String {
        switch self {
        case .missingRequiredField:
            return "필수값을 채워주세요."
        case .registeredUser:
            return "이미 등록된 회원입니다."
        case .unknownError:
            return "알수없는 오류입니다."
        }
    }
}
