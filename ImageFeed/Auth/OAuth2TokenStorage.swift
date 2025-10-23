//
//  OAuth2TokenStorage.swift
//  ImageFeed
//

import UIKit

final class OAuth2TokenStorage{
    let tokenKey = "Bearer Token"
    var token: String?{
        get {
            UserDefaults().string(forKey: tokenKey)
        }
        set {
            UserDefaults().set(newValue, forKey: tokenKey)
        }
    }
}
