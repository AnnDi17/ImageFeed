//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//

import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol{
    
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    var viewDidLoadCalled = false
    var getNewPhotosCalled = false
    var didChangeLikeCalled = false
    var getUrlForFullSizePhotoCalled = false
    var configImageCellCalled = false
    var getHeightForViewCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func getNewPhotos(_ completion: @escaping (Result<[Photo], Error>) -> Void) {
        getNewPhotosCalled = true
        completion(.success([]))
    }
    
    func didChangeLike(_ row: Int, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        didChangeLikeCalled = true
        completion(.success(true))
    }
    
    func getUrlForFullSizePhoto(at row: Int) -> String {
        getUrlForFullSizePhotoCalled = true
        return photos[row].largeImageURL
    }
    
    func configImageCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        configImageCellCalled = true
    }
    
    func getHeightForView(at row: Int, width: CGFloat) -> CGFloat {
        getHeightForViewCalled = true
        return 70
    }
}
