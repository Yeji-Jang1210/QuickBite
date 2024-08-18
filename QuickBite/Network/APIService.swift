//
//  APIService.swift
//  QuickBite
//
//  Created by 장예지 on 8/15/24.
//

import Foundation
import Moya

class APIService {
    static let shared = APIService()
    
    var baseURL: URL {
        return URL(string: APIInfo.baseURL)!
    }
    
    var header: [String:String] {
        return [
            Header.contentType.rawValue: Header.json.rawValue,
            Header.sesacKey.rawValue: APIInfo.key
        ]
    }
    
    
}
