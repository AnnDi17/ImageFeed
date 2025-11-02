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
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchPhotosNextPage(username: String, token: String, _ completion: @escaping (Result<[Photo], Error>) -> Void){
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        var newPhotos: [Photo] = []
        
        assert(Thread.isMainThread)
        
        if task != nil {
            print("fetchPhotosNextPage: invalid request - another one task")
            completion(.failure(ImagesListServiceError.duplicateRequest))
            return
        }
        
        guard let request = getPhotosNextPageRequest(with: token, page: nextPage, perPage: perPage) else {
            print("fetchProfileImageURL: request for the image URL is not created")
            completion(.failure(ProfileImageError.createRequestError))
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
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["Info": newPhotos])
            case .failure(let error):
                print("fetchPhotosNextPage: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func getPhotosNextPageRequest(with authToken: String, page: Int, perPage: Int) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURL.absoluteString + "/photos") else {
            print("getPhotosNextPageRequest: error creating url")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("\(page)", forHTTPHeaderField: "page")
        request.setValue("\(perPage)", forHTTPHeaderField: "per_page")
        request.httpMethod = "GET"
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
            isLiked: image.isLiked
        )
        return photo
    }
    
}

