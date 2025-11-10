//
//  OAuth2TokenStorage.swift
//  ImageFeed
//

import UIKit
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol: AnyObject {
    var token: String? {get set}
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol{
    static let shared = OAuth2TokenStorage()
    
    private init() {}
    let tokenKey = "Bearer Token"
    var token: String?{
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            }
            else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
