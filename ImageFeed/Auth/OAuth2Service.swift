//
//  OAuth2Service.swift
//  ImageFeed
//

import UIKit

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
}

enum OAuthError: Error {
    case createRequestError
    case invalidRequest
}

final class OAuth2Service{
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void){
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                print("fetchOAuthToken: invalid request - another one task with the same code")
                completion(.failure(OAuthError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                print("fetchOAuthToken: invalid request - another one task with the same code")
                completion(.failure(OAuthError.invalidRequest))
                return
            }
        }
        lastCode = code
        guard let request = getTokenRequest(code: code) else{
            print("fetchOAuthToken: request for the token is not created")
            completion(.failure(OAuthError.createRequestError))
            return }
        let task = URLSession.shared.objectTask(for: request){ [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result{
            case .success(let data):
                completion(.success(data.access_token))
            case .failure(let error):
                print("fetchOAuthToken: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        }
        self.task = task
        task.resume()
    }
    
    private func getTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashGetTokenURLString) else {
            print("getTokenRequest: error creating URL components")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else {
            print("getTokenRequest: error creating URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
