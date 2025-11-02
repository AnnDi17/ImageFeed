//
//  ProfileService.swift
//  ImageFeed
//

import UIKit

struct ProfileResult: Decodable {
    let username: String
    let first_name: String
    let last_name: String
    let bio: String?
}

enum ProfileError: Error {
    case createRequestError
    case invalidRequest
}

final class ProfileService {
    
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void){
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = getProfileRequest(with: token) else{
            print("fetchProfile: request for the profile is not created")
            completion(.failure(ProfileError.createRequestError))
            return }
        let task = urlSession.objectTask(for: request){ [weak self] (result: Result<ProfileResult, Error>) in
            switch result{
            case .success(let data):
                let profile = Profile(
                    username: data.username,
                    name: data.first_name + " " + data.last_name,
                    bio: data.bio ?? ""
                )
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("fetchProfile: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
    
    private func getProfileRequest(with authToken: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURL.absoluteString + "/me") else {
            print("getProfileRequest: error creating url")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
}

