//
//  ProfileViewController.swift
//  ImageFeed
//

import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profilePhotoView = createProfileView()
        let nameLabel = createNameLabel()
        let nicknameLabel = createNicknameLabel()
        let descriptionLabel = createDescriptionLabel()
        let exitButton = createExitButton()
        
        view.addSubviews([
            profilePhotoView,
            nameLabel,
            nicknameLabel,
            descriptionLabel,
            exitButton
        ])
        
        NSLayoutConstraint.activate([
            profilePhotoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profilePhotoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profilePhotoView.widthAnchor.constraint(equalToConstant: 70),
            profilePhotoView.heightAnchor.constraint(equalTo: profilePhotoView.widthAnchor),
            nameLabel.topAnchor.constraint(equalTo: profilePhotoView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nicknameLabel.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalTo: exitButton.widthAnchor),
            exitButton.centerYAnchor.constraint(equalTo: profilePhotoView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func createProfileView() -> UIImageView{
        let imageForProfile = UIImage(resource: .profilePhoto)
        let profilePhotoView = UIImageView(image: imageForProfile)
        return profilePhotoView
    }
    
    private func createNameLabel() -> UILabel{
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
        return nameLabel
    }
    
    private func createNicknameLabel() -> UILabel{
        let nicknameLabel = UILabel()
        nicknameLabel.text = "@ekaterina_nov"
        nicknameLabel.font = UIFont.systemFont(ofSize: 13)
        nicknameLabel.textColor = .YPGray
        return nicknameLabel
    }
    
    private func createDescriptionLabel() -> UILabel{
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        return descriptionLabel
    }
    
    private func createExitButton() -> UIButton{
        let exitButton = UIButton()
        let imageForExit = UIImage(resource: .exit)
        exitButton.setImage(imageForExit, for: .normal)
        return exitButton
    }
}
