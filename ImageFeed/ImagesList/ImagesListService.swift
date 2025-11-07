//
//  ImagesListService.swift
//  ImageFeed
//

import UIKit

enum ImagesListServiceError: Error {
    case duplicateRequest
    case createRequestError
    case invalidRequest
}

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private lazy var dateFormatter = ISO8601DateFormatter()
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private let perPage = 10
    
    private let urlSession = URLSession.shared
    private var taskForNextPage: URLSessionTask?
    private var taskForLike: URLSessionTask?
    
    private init() {}
    
    func fetchPhotosNextPage(token: String, _ completion: @escaping (Result<[Photo], Error>) -> Void){
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        var newPhotos: [Photo] = []
        
        assert(Thread.isMainThread)
        
        if taskForNextPage != nil {
            print("fetchPhotosNextPage: invalid request - another one task")
            completion(.failure(ImagesListServiceError.duplicateRequest))
            return
        }
        
        guard let request = getPhotosNextPageRequest(with: token, page: nextPage, perPage: perPage) else {
            print("fetchPhotosNextPage: request for the image URL is not created")
            completion(.failure(ImagesListServiceError.createRequestError))
            return
        }
        
        let task = urlSession.objectTask(for: request){ [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let data):
                data.forEach {
                    let photo = self.convertToPhoto($0)
                    newPhotos.append(photo)
                }
                self.photos.append(contentsOf: newPhotos)
                lastLoadedPage = nextPage
                completion(.success(newPhotos))
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["Info": newPhotos])
            case .failure(let error):
                print("fetchPhotosNextPage: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.taskForNextPage = nil
        }
        self.taskForNextPage = task
        task.resume()
    }
    
    private func getPhotosNextPageRequest(with token: String, page: Int, perPage: Int) -> URLRequest? {
        
        var urlComponents = URLComponents(string: Constants.defaultBaseURL.absoluteString + "/photos")
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = urlComponents?.url else {
            print("getPhotosNextPageRequest: error creating url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func changeLike(with token: String, photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        if taskForLike != nil {
            print("changeLike: invalid request - another one task")
            completion(.failure(ImagesListServiceError.duplicateRequest))
            return
        }
        
        guard let request = changeLikeRequest(with: token, id: photoId, isLike: isLike) else {
            print("changeLike: request for the image URL is not created")
            completion(.failure(ImagesListServiceError.createRequestError))
            return
        }
        
        let task = urlSession.objectTask(for: request){ [weak self] (result: Result<SinglePhoto, Error>) in
            guard let self else { return }
            switch result {
            case .success(let data):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: data.photo.isLiked,
                        isLoaded: photo.isLoaded,
                        thumbImageSize: photo.thumbImageSize
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                completion(.success(()))
            case .failure(let error):
                print("changeLike: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.taskForLike = nil
        }
        self.taskForLike = task
        task.resume()
    }
    
    private func changeLikeRequest(with authToken: String, id: String, isLike: Bool) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURL.absoluteString + "/photos/\(id)/like") else {
            print("changeLikeRequest: error creating url")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? "POST":"DELETE"
        return request
    }
    
    private func convertToPhoto(_ image: PhotoResult) -> Photo {
        let photo = Photo(
            id: image.id,
            size: CGSize(width: image.width, height: image.height),
            createdAt: dateFormatter.date(from: image.createdAt),
            welcomeDescription: image.description,
            thumbImageURL: image.urls.thumb,
            largeImageURL: image.urls.full,
            isLiked: image.isLiked,
            isLoaded: false,
            thumbImageSize: .zero
        )
        return photo
    }
    
    func cleanData(){
        photos = []
    }
}

