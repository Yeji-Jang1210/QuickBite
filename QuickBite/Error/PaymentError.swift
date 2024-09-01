//
//  PaymentError.swift
//  QuickBite
//
//  Created by 장예지 on 9/1/24.
//

import Foundation

enum PaymentError: Int {
    case badRequest = 400
    case invalidAccessToken = 401
    case forbodden = 403
    case paymentAlreadyProcessed = 409
    case postNotFound = 410
    case accessTokenExpired = 419
    
    var message: String {
        switch self {
        case .badRequest:
            return "유효하지 않는 결제건입니다.\n결제금액은 11시 이후 자동취소 됩니다."
        case .invalidAccessToken:
            return "인증할 수 없는 액세스 토큰입니다."
        case .forbodden:
            return "잘못된 접근입니다."
        case .paymentAlreadyProcessed:
            return "검증 처리가 완료된 결제건입니다."
        case .postNotFound:
            return "게시글을 찾을 수 없습니다."
        case .accessTokenExpired:
            return "액세스 토큰이 만료되었습니다."
        }
    }
}

