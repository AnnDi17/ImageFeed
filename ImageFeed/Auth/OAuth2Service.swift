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
}

final class OAuth2Service{
    static let shared = OAuth2Service()
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void){
        //ошибки пробрасываю в замыкание и вывожу в консоль в основном вызове = > здесь print не нужен
        guard let request = getTokenRequest(code: code) else{
            completion(.failure(OAuthError.createRequestError))
            return }
        let task = URLSession.shared.data(for: request){ result in
            switch result{
            case .success(let data):
                do {
                    let token = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(token.access_token))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func getTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashGetTokenURLString) else {
            print("Error creating URL components")
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
            print("Error creating URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
