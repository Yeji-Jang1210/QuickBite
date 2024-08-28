//
//  UploadPostError.swift
//  QuickBite
//
//  Created by 장예지 on 8/27/24.
//

import Foundation

enum UploadPostError: Int {
    case badRequest = 400
    case invalidAccessToken = 401
    case forbodden = 403
    case emptyPost = 410
    
    var message: String {
        switch self {
        case .badRequest:
            return "유효하지 않은 값 타입입니다."
        case .invalidAccessToken:
            return "인증할 수 없는 액세스 토큰입니다."
        case .forbodden:
            return "잘못된 접근입니다"
        case .emptyPost:
            return "생성된 게시글이 없습니다."
        }
    }
}
