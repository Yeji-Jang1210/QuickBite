//
//  UploadFileError.swift
//  QuickBite
//
//  Created by 장예지 on 8/27/24.
//

import Foundation

enum UploadFileError: Int {
    case badRequest = 400
    case invalidAccessToken = 401
    case forbodden = 403
    
    var message: String {
        switch self {
        case .badRequest:
            return "파일의 제한 사항과 맞지 않습니다."
        case .invalidAccessToken:
            return "인증할 수 없는 액세스 토큰입니다."
        case .forbodden:
            return "잘못된 접근입니다"
        }
    }
}
