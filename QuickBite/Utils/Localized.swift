//
//  Localized.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import Foundation

enum Localized {
    case title
    case signin_button
    case email_textField_placeholder
    case password_textField_placeholder
    
    case signup
    case signup_description
    case signup_optional
    case signup_birtday_placeholder
    case signup_phoneNumber_placeholder
    
    var title: String {
        switch self {
        case .title:
            return "한끼뚝딱"
        case .signin_button:
            return "로그인"
        case .signup:
            return "회원가입"
        default:
            return ""
        }
    }
    
    var text: String {
        switch self {
        case .email_textField_placeholder:
            return "이메일을 입력해주세요."
        case .password_textField_placeholder:
            return "비밀번호를 입력해주세요."
        case .signup_description:
            return "요리사님이 누구인지 알려주세요!"
        case .signup_birtday_placeholder:
            return "생년월일을 입력해주세요. (yyyyMMdd 8자리)"
        case .signup_phoneNumber_placeholder:
            return "휴대폰 번호를 - 없이 입력해주세요."
        case .signup_optional:
            return "선택사항"
        default:
            return ""
        }
    }
}
