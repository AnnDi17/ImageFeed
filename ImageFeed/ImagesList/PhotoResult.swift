//
//  PhotoResult.swift
//  ImageFeed
//
import UIKit

struct SinglePhoto: Decodable {
    let photo: PhotoResult
}

struct PhotoResult: Decodable {
    
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let description: String?
    let urls: UrlsResult
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case isLiked = "liked_by_user"
    }
}

