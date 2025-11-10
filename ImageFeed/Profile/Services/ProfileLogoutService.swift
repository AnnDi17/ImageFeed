//
//  ProfileLogoutService.swift
//  ImageFeed
//

import Foundation
import WebKit

protocol ProfileLogoutServiceProtocol {
    func logout()
}

final class ProfileLogoutService: ProfileLogoutServiceProtocol {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene else {
            assertionFailure("switchToAuthController: invalid window scene configuration")
            return
        }
        guard let window = windowScene.windows.first else {
            assertionFailure("switchToAuthController: invalid window configuration")
            return
        }
         window.rootViewController = SplashViewController()
         window.makeKeyAndVisible()
        
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        ProfileService.shared.cleanData()
        ProfileImageService.shared.cleanData()
        ImagesListService.shared.cleanData()
        OAuth2TokenStorage.shared.token = nil
    }
    
}
