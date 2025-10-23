//
//  AuthViewController.swift
//  ImageFeed
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
    var storage: OAuth2TokenStorage { get }
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    @IBOutlet private weak var loginButton: UIButton!
    
    private enum segueIdentifier: String {
        case ShowWebView
    }
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier.ShowWebView.rawValue {
            guard let webViewViewController = segue.destination as? WebViewViewController else { return }
            webViewViewController.delegate = self
        } else{
            super.prepare(for: segue, sender: sender)
        }
        
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor.YPBlack
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.navigationController?.popViewController(animated: true)
        OAuth2Service.shared.fetchOAuthToken(code: code){[weak self] result in
            guard let self=self else { return }
            switch result {
            case .success(let token):
                delegate?.storage.token = token
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                vc.dismiss(animated: true)
                print("Error: \(error)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
}
