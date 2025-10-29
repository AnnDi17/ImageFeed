//
//  TabBarController.swift
//  ImageFeed
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        )
        
        imagesListViewController.tabBarItem.image = UIImage(resource: .tabEditorialNoactive)
        imagesListViewController.tabBarItem.selectedImage = UIImage(resource: .tabEditorialActive)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileNoactive),
            selectedImage: UIImage(resource: .tabProfileActive)
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
