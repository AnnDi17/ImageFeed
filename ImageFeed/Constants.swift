//
//  Constants.swift
//  ImageFeed
//

import Foundation

enum Constants{
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashGetTokenURLString = "https://unsplash.com/oauth/token"
    static let accessKey = "oonGRjyYqdyrfcfIJIkpBCWam_i2hVMD_Bzqe8n1O7A"
    static let secretKey = "fiudEk3gPIWb84En3gyDyzh3irlmS6mdHKbWiNhXzy0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL : URL = URL(string: "https://api.unsplash.com")!
}
