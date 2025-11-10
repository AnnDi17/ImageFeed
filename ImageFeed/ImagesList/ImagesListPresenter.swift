//
//  ImagesListPresenter.swift
//  ImageFeed
//

import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] {get set}
    
    func viewDidLoad()
    func getNewPhotos(_ completion: @escaping (Result<[Photo], Error>) -> Void)
    func didChangeLike(_ row: Int, _ completion: @escaping (Result<Bool, Error>) -> Void)
    func getUrlForFullSizePhoto(at: Int) -> String
    func configImageCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func getHeightForView(at row: Int, width: CGFloat) -> CGFloat 
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let imagesListService: ImagesListServiceProtocol
    private let tokenStorage: OAuth2TokenStorageProtocol
    private var imageListServiceObserver: NSObjectProtocol?
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared,
         tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage.shared) {
        
        self.imagesListService = imagesListService
        self.tokenStorage = tokenStorage
    }
    
    func viewDidLoad() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.photos = self.imagesListService.photos
            self.view?.photosCountDidUpdate()
        }
        
        imageListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self else { return }
                if let newPhotos = notification.userInfo?["Info"] as? [Photo] {
                    self.photos.append(contentsOf: newPhotos)
                } else {
                    self.photos = imagesListService.photos
                }
                self.view?.photosCountDidUpdate()
            }
        
    }
    
    func getNewPhotos(_ completion: @escaping (Result<[Photo], Error>) -> Void){
        imagesListService.fetchPhotosNextPage(token: tokenStorage.token ?? ""){ result in
            completion(result)
        }
    }
    
    func getUrlForFullSizePhoto(at row: Int) -> String{
        return photos[row].largeImageURL
    }
    
    func getHeightForView(at row: Int, width: CGFloat) -> CGFloat {
        
        var size: CGSize
        let image = photos[row]
        if photos.count > row && image.isLoaded {
            size = image.thumbImageSize
        }
        else {
            let imageStub = UIImage(resource: .stub)
            size = imageStub.size
        }
        
        let wView = width
        let wImage = size.width
        let hImage = size.height
        let k = wView / wImage
        var height = hImage * k
        height += 8 //top and bottom constraints
        
        return height
    }
    
    func didChangeLike(_ row: Int, _ completion: @escaping (Result<Bool, Error>) -> Void){
        let photo = photos[row]
        imagesListService.changeLike(with: tokenStorage.token ?? "", photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else {return}
            switch result {
            case .success():
                photos[row].isLiked = self.imagesListService.photos[row].isLiked
                completion(.success(photos[row].isLiked))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func configImageCell(for cell: ImagesListCell, with indexPath: IndexPath){
        guard let url = URL(string: photos[indexPath.row].thumbImageURL) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else {return}
            self.view?.setImage(for: cell, with: url) {result in
                switch result {
                case .success(let data):
                    if self.photos[indexPath.row].isLoaded {
                        if let date = self.photos[indexPath.row].createdAt {
                            let text = self.dateFormatter.string(from: date)
                            self.view?.configLabel(for: cell, with: text)
                        } else {
                            self.view?.configLabel(for: cell, with: "")
                        }
                        self.view?.configLikeButton(for: cell, isLiked: self.photos[indexPath.row].isLiked)
                    } else {
                        self.photos[indexPath.row].isLoaded = true
                        self.photos[indexPath.row].thumbImageSize = data.image.size
                        self.view?.didUpdateCell(at: indexPath)
                    }
                case .failure(let error):
                    print("ImagesListPresenter.configImageCell: \(error.localizedDescription), row: \(indexPath.row)")
                }
            }
        }
    }
}
