//
//  ProfileViewTests.swift
//  ImageFeedTests
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsPresenter() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsGetProfile() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.getProfileCalled)
    }
    
    func testLogout_CallsPresenterDidExit() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.perform(#selector(ProfileViewController.logout))
        
        //then
        XCTAssertTrue(presenter.didCallDidExit)
    }
    
    func testUpdateAvatar() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let bundle = Bundle(for: Self.self)
        guard
            let fileURL = bundle.url(forResource: "testPhoto", withExtension: "png"),
            let testImage = UIImage(contentsOfFile: fileURL.path),
            let testImageData = testImage.pngData()
        else {
            XCTFail("testPhoto.png is not found")
            return
        }
        let exp = expectation(description: "Avatar image is set")
        
        //when
        viewController.updateAvatar(with: fileURL)
        
        //then
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let image = viewController.profilePhotoImageView.image,
               let data = image.pngData(),
               data == testImageData {
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func testNotificationObserver_CallsPresenterAvatarDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        NotificationCenter.default.post(
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    
        //then
        let exp = expectation(description: "avatarDidLoad called from notification")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if presenter.didCallAvatarDidLoad {
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 10.0)
    }
}
