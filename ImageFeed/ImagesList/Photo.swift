//
//  Photo.swift
//  ImageFeed
//
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    var isLoaded: Bool
    var thumbImageSize: CGSize
}
