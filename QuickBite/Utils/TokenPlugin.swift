//
//  TokenPlugin.swift
//  QuickBite
//
//  Created by 장예지 on 8/28/24.
//

import Foundation
import Kingfisher

final class TokenPlugin: ImageDownloadRequestModifier {
    let token: String
    
    init(token: String){
        self.token = token
    }
    
    func modified(for request: URLRequest) -> URLRequest? {
        var request = request
        
        request.addValue(UserDefaultsManager.shared.token, forHTTPHeaderField: Header.authorization.rawValue)
        request.addValue(APIInfo.key, forHTTPHeaderField: Header.sesacKey.rawValue)
        return request
    }
}
