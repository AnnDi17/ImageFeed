//
//  Constants.swift
//  ImageFeed
//

import Foundation

enum Constants{
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashGetTokenURLString = "https://unsplash.com/oauth/token"
    static let defaultBaseURL : URL = URL(string: "https://api.unsplash.com")!
    
    static let accessKey = "oonGRjyYqdyrfcfIJIkpBCWam_i2hVMD_Bzqe8n1O7A"
    static let secretKey = "fiudEk3gPIWb84En3gyDyzh3irlmS6mdHKbWiNhXzy0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
