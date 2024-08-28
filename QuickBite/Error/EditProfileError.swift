//
//  EditProfileError.swift
//  QuickBite
//
//  Created by 장예지 on 8/28/24.
//

import Foundation

enum EditProfileError: Int {
    case badRequest = 400
    case missingRequiredField = 401
    case containsWhiteSpaceAtNickname = 402
    case forbiddenAccess = 403
    case registeredUser = 409
    case unknownError
    
    var message: String {
        switch self {
        case .badRequest:
            return "파일의 제한 사항과 맞지 않습니다."
        case .missingRequiredField:
            return "인증할 수 없는 액세스 토큰입니다."
        case .containsWhiteSpaceAtNickname:
            return "공백이 포함된 닉네임은 사용할 수 없습니다."
        case .forbiddenAccess:
            return "접근 권한이 없습니다."
        case .registeredUser:
            return "이미 사용중인 닉네임입니다."
        case .unknownError:
            return "알 수 없는 오류입니다."
        }
    }
}
