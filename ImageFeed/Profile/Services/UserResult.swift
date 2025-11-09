//
//  UserResult.swift
//  ImageFeed
//

struct UserResult: Decodable {
    let profileImage: ImageURL
    
    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ImageURL: Decodable{
    let small: String
    let medium: String
    let large: String
}

