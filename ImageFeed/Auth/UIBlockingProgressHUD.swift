//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene else {
            assertionFailure("UIBlockingProgressHUD: invalid window scene configuration")
            return nil
        }
        guard let window = windowScene.windows.first else {
            assertionFailure("UIBlockingProgressHUD: invalid window configuration")
            return nil
        }
        return window
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}

