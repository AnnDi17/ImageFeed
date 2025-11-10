//
//  TabBarController.swift
//  ImageFeed
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {return }
        
        imagesListViewController.tabBarItem.image = UIImage(resource: .tabEditorialNoactive)
        imagesListViewController.tabBarItem.selectedImage = UIImage(resource: .tabEditorialActive)
        
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.configure(imagesListPresenter)
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileNoactive),
            selectedImage: UIImage(resource: .tabProfileActive)
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
