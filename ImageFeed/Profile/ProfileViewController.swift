//
//  ProfileViewController.swift
//  ImageFeed
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func showExitAlert(handler: @escaping ()->Void)
    func updateAvatar(with url: URL)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    private(set) var profilePhotoImageView = UIImageView()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    var presenter: ProfilePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        let profileData = presenter?.getProfile()
        
        let nameLabel = createNameLabel(with: profileData?.name)
        let nicknameLabel = createNicknameLabel(with: profileData?.loginName)
        let descriptionLabel = createDescriptionLabel(with: profileData?.bio)
        let exitButton = createExitButton()
        
        view.backgroundColor = .YPBlack
        
        view.addSubviews([
            profilePhotoImageView,
            nameLabel,
            nicknameLabel,
            descriptionLabel,
            exitButton
        ])
        
        settingsForProfileView()
        
        NSLayoutConstraint.activate([
            profilePhotoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profilePhotoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profilePhotoImageView.widthAnchor.constraint(equalToConstant: 70),
            profilePhotoImageView.heightAnchor.constraint(equalTo: profilePhotoImageView.widthAnchor),
            nameLabel.topAnchor.constraint(equalTo: profilePhotoImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profilePhotoImageView.leadingAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nicknameLabel.leadingAnchor.constraint(equalTo: profilePhotoImageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profilePhotoImageView.leadingAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor),
            exitButton.centerYAnchor.constraint(equalTo: profilePhotoImageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.presenter?.avatarDidLoad()
            }
    }
    
    func updateAvatar(with url: URL) {
        profilePhotoImageView.kf.setImage(
            with: url)
    }
    
    func showExitAlert(handler: @escaping ()->Void) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default){_ in
            handler()
        }
        alert.addAction(yesAction)
        let noAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func settingsForProfileView() -> Void {
        profilePhotoImageView.layer.cornerRadius = 35
        profilePhotoImageView.layer.masksToBounds = true
    }
    
    private func createNameLabel(with text: String?) -> UILabel{
        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
        nameLabel.text = text ?? ""
        return nameLabel
    }
    
    private func createNicknameLabel(with text: String?) -> UILabel{
        let nicknameLabel = UILabel()
        nicknameLabel.font = UIFont.systemFont(ofSize: 13)
        nicknameLabel.textColor = .YPGray
        nicknameLabel.text = text ?? ""
        return nicknameLabel
    }
    
    private func createDescriptionLabel(with text: String?) -> UILabel{
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        descriptionLabel.text = text ?? ""
        return descriptionLabel
    }
    
    private func createExitButton() -> UIButton{
        let exitButton = UIButton()
        let imageForExit = UIImage(resource: .exit)
        exitButton.accessibilityIdentifier = "logout button"
        exitButton.setImage(imageForExit, for: .normal)
        exitButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return exitButton
    }
    
    @objc func logout(){
        presenter?.didExit()
    }
    
}
