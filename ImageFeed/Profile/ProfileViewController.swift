//
//  ProfileViewController.swift
//  ImageFeed
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var profilePhotoImageView = UIImageView()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .YPBlack
        
        let nameLabel = createNameLabel()
        let nicknameLabel = createNicknameLabel()
        let descriptionLabel = createDescriptionLabel()
        let exitButton = createExitButton()
        
        view.addSubviews([
            profilePhotoImageView,
            nameLabel,
            nicknameLabel,
            descriptionLabel,
            exitButton
        ])
        
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
        
        nameLabel.text = ProfileService.shared.profile?.name
        nicknameLabel.text = ProfileService.shared.profile?.loginName
        descriptionLabel.text = ProfileService.shared.profile?.bio
        settingsForProfileView()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        profilePhotoImageView.kf.setImage(
            with: url)
    }
    
    private func settingsForProfileView() -> Void {
        profilePhotoImageView.layer.cornerRadius = 35
        profilePhotoImageView.layer.masksToBounds = true
    }
    
    private func createNameLabel() -> UILabel{
        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
        return nameLabel
    }
    
    private func createNicknameLabel() -> UILabel{
        let nicknameLabel = UILabel()
        nicknameLabel.font = UIFont.systemFont(ofSize: 13)
        nicknameLabel.textColor = .YPGray
        return nicknameLabel
    }
    
    private func createDescriptionLabel() -> UILabel{
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        return descriptionLabel
    }
    
    private func createExitButton() -> UIButton{
        let exitButton = UIButton()
        let imageForExit = UIImage(resource: .exit)
        exitButton.setImage(imageForExit, for: .normal)
        exitButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return exitButton
    }
    
    @objc private func logout(){
        showExitAlert(){
            ProfileLogoutService.shared.logout()
        }
    }
    
    private func showExitAlert(handler: @escaping ()->Void) {
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
    
}
