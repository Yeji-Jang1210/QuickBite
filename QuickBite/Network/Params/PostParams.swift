//
//  PostParams.swift
//  QuickBite
//
//  Created by 장예지 on 8/27/24.
//

import Foundation
import Moya

class PostParams {
//MARK: Request
    struct FileUploadRequest: Codable {
        let files: [ImageData]
        
        func convertMultiPartFormData() -> [MultipartFormData] {

            var multipartFormData: [MultipartFormData] = []
            
            for file in files {
                multipartFormData.append(MultipartFormData(provider: .data(file.image), name: "files", fileName: file.name, mimeType: "image/png"))
            }
            
            return multipartFormData
            
        }
    }
    
    struct AddPostRequest: Codable {
        let title: String
        let content: String
        var product_id: String = "quickBite"
        let files: [String]?
    }

//MARK: Response
    struct FileUploadResponse: Codable {
        let files: [String]
    }
    
    struct AddPostResponse: Codable {
        let post_id: String
        let product_id: String
        let title: String
        let content: String
        let createdAt: String
        let creator: Creator
        let files: [String]
    }
}

struct Creator: Codable {
    let user_id: String
    let nick: String
    let profileImage: String?
}
