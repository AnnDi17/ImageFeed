//
//  ProfileResult.swift
//  ImageFeed
//

struct ProfileResult: Decodable {
    let username: String
    let first_name: String
    let last_name: String?
    let bio: String?
}
