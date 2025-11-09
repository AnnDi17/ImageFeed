//
//  ProfilePresenterSpy.swift
//  ImageFeed
//

import Foundation
@testable import ImageFeed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var getProfileCalled: Bool = false
    var didCallDidExit: Bool = false
    var didCallAvatarDidLoad: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func getProfile() -> ImageFeed.Profile {
        getProfileCalled = true
        return Profile(username: "", name: "", bio: "")
    }
    
    func didExit() {
        didCallDidExit = true
    }
    
    func avatarDidLoad() {
        didCallAvatarDidLoad = true
    }
    
}
