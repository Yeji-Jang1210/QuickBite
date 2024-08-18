//
//  EmailValidationState.swift
//  QuickBite
//
//  Created by 장예지 on 8/18/24.
//

import UIKit

enum EmailValidationState {
    case valid
    case isEmpty
    case missingAtSymbol
    case missingDomain
    case missingLocalPart
    case invalidCharacters
    case invalidDomainFormat
    case tooShort
    case tooLong
    
    var description: String {
        switch self {
        case .valid:
            return "유효한 이메일 주소입니다."
        case .isEmpty:
            return "이메일을 입력해주세요."
        case .missingAtSymbol:
            return "이메일 주소에 '@' 기호가 없습니다."
        case .missingDomain:
            return "도메인 부분이 없습니다."
        case .missingLocalPart:
            return "로컬 파트 부분이 없습니다."
        case .invalidCharacters:
            return "잘못된 문자가 포함되어 있습니다."
        case .invalidDomainFormat:
            return "도메인 형식이 잘못되었습니다."
        case .tooShort:
            return "이메일 주소가 너무 짧습니다."
        case .tooLong:
            return "이메일 주소가 너무 깁니다."
        }
    }
    
    // 이메일 상태를 판별하는 함수
    static func validateEmail(_ email: String) -> EmailValidationState {
        
        if email.isEmpty {
            return .isEmpty
        }
        
        // 이메일 길이 제한 (보통 1~254자)
        if email.count < 5 {
            return .tooShort
        } else if email.count > 254 {
            return .tooLong
        }
        
        // '@' 기호 확인
        guard email.contains("@") else {
            return .missingAtSymbol
        }
        
        // 로컬 파트와 도메인 분리
        let parts = email.split(separator: "@")
        guard parts.count == 2 else {
            return .invalidDomainFormat
        }
        
        let localPart = parts[0]
        let domainPart = parts[1]
        
        // 로컬 파트 확인
        if localPart.isEmpty {
            return .missingLocalPart
        }
        
        // 도메인 확인
        if domainPart.isEmpty {
            return .missingDomain
        }
        
        // 도메인 형식 확인 (최상위 도메인이 있는지)
        if !domainPart.contains(".") {
            return .invalidDomainFormat
        }
        
        // 유효한 문자 체크 (아래는 기본적인 예제, 필요에 따라 확장 가능)
        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._%+-")
        if localPart.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return .invalidCharacters
        }
        
        return .valid
    }
}
