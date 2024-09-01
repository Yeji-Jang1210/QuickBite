//
//  PaymentParams.swift
//  QuickBite
//
//  Created by 장예지 on 9/1/24.
//

import Foundation

class PaymentParams {
    struct ValidationRequest: Codable {
        let imp_uid: String
        let post_id: String
    }
    
    struct ValidationResponse: Codable {
        let buyer_id: String
        let post_id: String
        let merchant_uid: String
        let productName: String
        let price: Int
        let paidAt: String
    }
}
