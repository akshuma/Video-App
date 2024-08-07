//
//  VideoViewModel.swift
//  VideosApp
//
//  Created by Akshu on 04/08/24.
//

import Foundation

protocol VideoViewModelDelegate: AnyObject {
    func didUpdateVideoItems()
    func didFailWithError(error: Error)
}

protocol VideoCollectionViewModelProtocol {
    var delegate: VideoViewModelDelegate? { get set }
    var videoItems: [VideoItem] { get }
    func fetchVideoData()
}

class VideoViewModel {
    private let videoItem: VideoItem

    init(videoItem: VideoItem) {
        self.videoItem = videoItem
    }

    var id: String {
        return videoItem.id
    }

    var videoURL: URL {
        return videoItem.video
    }

    var thumbnailURL: URL {
        return videoItem.thumbnail
    }
}

class VideoCollectionViewModel: VideoCollectionViewModelProtocol {
    weak var delegate: VideoViewModelDelegate?
    private let apiService: APIServiceProtocol
    private(set) var videoItems: [VideoItem] = []
    
    init(apiService: APIServiceProtocol = MockAPIService()) {
        self.apiService = apiService
    }
    
    func fetchVideoData() {
        apiService.fetchVideoData { [weak self] result in
            switch result {
            case .success(let videoResponse):
                guard let reels = videoResponse.reels, let self = self else {
                    print("No reels found in the JSON data")
                    return
                }
                
                self.videoItems = reels.flatMap { $0.arr }
                self.preloadVideosAndThumbnails()
                DispatchQueue.main.async {
                    self.delegate?.didUpdateVideoItems()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.delegate?.didFailWithError(error: error)
                }
            }
        }
    }
    
    private func preloadVideosAndThumbnails() {
        for videoItem in videoItems {
            VideoManager.shared.cacheThumbnail(from: videoItem.thumbnail) { _ in }
            VideoManager.shared.cacheVideo(from: videoItem.video) { _ in }
        }
    }
    
}
