//
//  SplashViewController.swift
//  ImageFeed
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let token = OAuth2TokenStorage.shared.token else {
            
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController else {
                assertionFailure("viewDidAppear: failed to create AuthViewController")
                return
            }
            authViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: authViewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
            return
        }
        fetchProfile(token: token)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let splashImageView = UIImageView()
        
        view.backgroundColor = .YPBlack
        view.addSubviews([splashImageView])
        
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        splashImageView.image = UIImage(resource: .launchScreen)
    }
    
    //AuthViewControllerDelegate
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = OAuth2TokenStorage.shared.token else {
            return
        }
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username, token: token){ result in }
                ImagesListService.shared.fetchPhotosNextPage(token: token){ result in }
                self.switchToTabBarController()
            case .failure(let error):
                print("fetchProfile: \(error)")
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene else {
            assertionFailure("switchToTabBarController: invalid window scene configuration")
            return
        }
        guard let window = windowScene.windows.first else {
            assertionFailure("switchToTabBarController: invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}
