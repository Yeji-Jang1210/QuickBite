//
//  ValidationPhoneNumber.swift
//  QuickBite
//
//  Created by 장예지 on 8/23/24.
//

import Foundation

enum ValidationPhoneNumber {
    case onlyNumbersAllowed
    case require11DigitNumber
    case valid
    case isNumber
    
    var message: String {
        switch self {
        case .onlyNumbersAllowed:
            return "숫자만 입력해 주세요."
        case .require11DigitNumber, .isNumber:
            return "11자리 숫자로 입력해 주세요."
        case .valid:
            return ""
        }
    }
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        default:
            return false
        }
    }
    
    static func validatePhoneNumber(_ text: String, completion: @escaping (ValidationPhoneNumber) -> Void){
        
        if text.isEmpty {
            completion(.valid)
        }
        
        let text = text.replacingOccurrences(of: "-", with: "")

        if Int(text) == nil {
            completion(.onlyNumbersAllowed)
            return
        } else {
            completion(.isNumber)
        }
        
        if text.count != 11 {
            completion(.require11DigitNumber)
            return
        }
        
        completion(.valid)
        
    }
    
    static func format(phoneNumber: String) -> String {
        let text = phoneNumber.replacingOccurrences(of: "-", with: "")
        
        var formatted = ""
        let length = text.count
        
        if length > 0 {
            formatted += String(text.prefix(3))
        }
        if length > 3 {
            let start = text.index(text.startIndex, offsetBy: 3)
            let end = text.index(text.startIndex, offsetBy: min(7, length))
            formatted += "-" + text[start..<end]
        }
        if length > 7 {
            let start = text.index(text.startIndex, offsetBy: 7)
            formatted += "-" + text[start...]
        }
        
        return formatted
    }
}
