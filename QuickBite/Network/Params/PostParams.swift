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
    
    struct FetchPosts: Codable {
        let next: String? = ""
        let limit: String?
        var product_id = "quickBite"
        
        enum CodingKeys: String, CodingKey {
            case next
            case limit
            case product_id
        }
        
        func toParameters() -> [String: Any] {
            var params = [String: Any]()
            
            if let next = next {
                params["next"] = next
            }
            
            if let limit = limit {
                params["limit"] = limit
            }
            
            params["product_id"] = product_id
            
            return params
        }
        
        
    }
    
    struct FetchSpecificPostRequest: Codable {
        let id: String
    }
    
    struct FetchUserPostsRequest: Codable {
        let id: String
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
    
    struct PostResponse: Codable {
        let post_id: String
        let product_id: String
        let title: String
        let content: String
        let createdAt: String
        let creator: Creator
        let files: [String]
        let next_cursor: String?
    }
    
    struct FetchUserPostsResponse: Codable {
        let data: [PostResponse]
    }
}

struct Creator: Codable {
    let user_id: String
    let nick: String
    let profileImage: String?
}
