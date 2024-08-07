//
//  NetworkManager.swift
//  VideosApp
//
//  Created by Akshu on 04/08/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

protocol APIServiceProtocol {
    func fetchVideoData(completion: @escaping (Result<VideoResponse, Error>) -> Void)
}

class MockAPIService: APIServiceProtocol {
    func fetchVideoData(completion: @escaping (Result<VideoResponse, Error>) -> Void) {
        if let url = Bundle.main.url(forResource: "mockReelsData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let videoResponse = try JSONDecoder().decode(VideoResponse.self, from: data)
                completion(.success(videoResponse))
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.failure(NSError(domain: "URL Error", code: 404, userInfo: nil)))
        }
    }
    
}
