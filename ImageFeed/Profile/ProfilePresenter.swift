//
//  ProfilePresenter.swift
//  ImageFeed
//
import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func getProfile() -> Profile
    func didExit()
    func avatarDidLoad()
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    var profileService: ProfileServiceProtocol
    var imageService: ProfileImageServiceProtocol
    var logoutService: ProfileLogoutServiceProtocol
    
    init(profileService: ProfileServiceProtocol = ProfileService.shared,
         imageService: ProfileImageServiceProtocol = ProfileImageService.shared,
         logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared) {
        
        self.profileService = profileService
        self.imageService = imageService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        avatarDidLoad()
    }
    
    func getProfile() -> Profile {
        let profile = Profile(
            username: profileService.profile?.username ?? "",
            name: profileService.profile?.name ?? "",
            bio: profileService.profile?.bio ?? ""
        )
        return profile
    }
    
    func didExit() {
        view?.showExitAlert(){
            self.logoutService.logout()
        }
    }
    
    func avatarDidLoad() {
        guard
            let profileImageURL = imageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        view?.updateAvatar(with: url)
    }
}

