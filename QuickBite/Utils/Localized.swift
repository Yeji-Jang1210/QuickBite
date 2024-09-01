//
//  Localized.swift
//  QuickBite
//
//  Created by 장예지 on 8/14/24.
//

import Foundation

enum Localized {
    case title
    case subtitle
    case signin_button
    case email_textField_placeholder
    case password_textField_placeholder
    case nickname_textField_placeholder
    case valid_email_button
    case login_invalid
    case signup
    case signup_description
    case signup_optional
    case signup_birtday_placeholder
    case signup_phoneNumber_placeholder
    case isSave
    case isDelete
    case loding
    
    case birthday_format(year: String, month: String, day: String)
    
    //mainVC
    case todayRecipes
    case main_payment
    
    //addPost
    case add_post_title
    
    var title: String {
        switch self {
        case .title:
            return "한끼뚝딱"
        case .subtitle:
            return "끼니를 해결할 간단한 레시피"
        case .signin_button:
            return "로그인"
        case .valid_email_button:
            return "중복확인"
        case .signup:
            return "회원가입"
        case .todayRecipes:
            return "오늘의 레시피"
        case .add_post_title:
            return "레시피 등록"
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
        case .nickname_textField_placeholder:
            return "닉네임을 입력해주세요."
        case .signup_description:
            return "요리사님이 누구인지 알려주세요!"
        case .signup_birtday_placeholder:
            return "생년월일을 입력해주세요. (yyyyMMdd 8자리)"
        case .signup_phoneNumber_placeholder:
            return "휴대폰 번호를 - 없이 입력해주세요."
        case .signup_optional:
            return "선택사항"
        case .birthday_format(let year, let month, let day):
            return "\(year)년 \(month)월 \(day)일"
        case .login_invalid:
            return "아이디 또는 비밀번호를 입력해주세요."
        case .isSave:
            return "저장되었습니다."
        case .isDelete:
            return "삭제되었습니다."
        case .main_payment:
            return "😮 이런 상품은 어때요?"
        case .loding:
            return "loding"
        default:
            return ""
        }
    }
    
    var description: String {
        switch self {
        case .todayRecipes:
            return "따끈따끈한 레시피들을 둘러보세요 🤤"
        default:
            return ""
        }
    }
}
