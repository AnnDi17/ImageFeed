//
//  ProfileImageService.swift
//  ImageFeed
//

import UIKit

enum ProfileImageError: Error {
    case createRequestError
    case invalidRequest
}

protocol ProfileImageServiceProtocol {
    var avatarURL: String? {get}
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, Error>) -> Void)
}

final class ProfileImageService: ProfileImageServiceProtocol {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, Error>) -> Void){
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = getProfileImageRequest(with: token, username: username) else{
            print("ProfileImageService.fetchProfileImageURL: request for the image URL is not created")
            completion(.failure(ProfileImageError.createRequestError))
            return }
        let task = urlSession.objectTask(for: request){ [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result{
            case .success(let data):
                self.avatarURL = data.profileImage.small
                completion(.success(data.profileImage.small))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": data.profileImage.small])
            case .failure(let error):
                print("ProfileImageService.fetchProfileImageURL: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func getProfileImageRequest(with authToken: String, username: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURL.absoluteString + "/users/\(username)") else {
            print("ProfileImageService.getProfileImageRequest: error creating url")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func cleanData() {
        self.avatarURL = nil
    }
}

