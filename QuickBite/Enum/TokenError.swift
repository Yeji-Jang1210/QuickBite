//
//  TokenError.swift
//  QuickBite
//
//  Created by 장예지 on 8/18/24.
//

import Foundation

enum TokenError: Int, Error {
    case invalidToken = 401
    case forbidden = 403
    case refreshTokenExpired = 418

    // 에러 상태에 따라 적절한 메시지를 제공
    var message: String {
        switch self {
        case .invalidToken:
            return "인증할 수 없는 토큰입니다. 다시 로그인해 주세요."
        case .forbidden:
            return "권한이 없습니다. 필요한 권한을 확인해 주세요."
        case .refreshTokenExpired:
            return "리프레시 토큰이 만료되었습니다. 다시 로그인해 주세요."
        }
    }
}
