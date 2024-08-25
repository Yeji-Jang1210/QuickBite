//
//  ValidationBirthday.swift
//  QuickBite
//
//  Created by 장예지 on 8/23/24.
//

import Foundation

enum ValidationBirthday {
    case invalidFormat
    case valid
    
    var message: String {
        switch self {
        case .invalidFormat:
            return "형식에 맞게 입력해주세요"
        case .valid:
            return ""
        }
    }
    
    var isValid: Bool {
        switch self {
        case .invalidFormat:
            return false
        case .valid:
            return true
        }
    }
    
    static func validateBirthday(_ text: String, completion: @escaping (ValidationBirthday)->Void){
        if text.isEmpty {
            completion(.valid)
            return
        }
        
        isValidDateFormat(text) ? completion(.valid) : completion(.invalidFormat)
        
    }
    
    static func isValidDateFormat(_ dateString: String) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
    
        if let _ = dateFormatter.date(from: dateString) {
            return true
        } else {
            return false
        }
    }
    
    static func format(_ date: String) -> String {
        let yearStartIndex = date.index(date.startIndex, offsetBy: 4)
        let year = "\(date[date.startIndex..<yearStartIndex])"
        
        let monthStartIndex = date.index(date.startIndex, offsetBy: 4) //5
        let month = "\(date[monthStartIndex..<date.index(monthStartIndex, offsetBy: 2)])"


        let dayStartIndex = date.index(monthStartIndex, offsetBy: 2)
        let day = "\(date[dayStartIndex..<date.index(dayStartIndex, offsetBy:2)])"
        
        return Localized.birthday_format(year: year, month: month, day: day).text
    }
}
