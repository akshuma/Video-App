//
//  VideoManager.swift
//  VideosApp
//
//  Created by Akshu on 06/08/24.
//

import Foundation
import UIKit

class VideoManager {
    static let shared = VideoManager()
    
    private var videoCache = NSCache<NSURL, NSURL>()
    private var thumbnailCache = NSCache<NSURL, UIImage>()
    
    // Preload video and thumbnail
    func preloadVideoAndThumbnail(from url: URL, completion: @escaping (URL?, UIImage?) -> Void) {
        // Check thumbnail cache
        if let cachedThumbnail = thumbnailCache.object(forKey: url as NSURL) {
            // Check video cache
            if let cachedURL = videoCache.object(forKey: url as NSURL) {
                completion(cachedURL as URL, cachedThumbnail)
                return
            }
            
            // Video not cached, start downloading
            downloadVideo(from: url) { [weak self] videoURL in
                completion(videoURL, cachedThumbnail)
            }
        } else {
            // Download thumbnail first
            cacheThumbnail(from: url) { [weak self] thumbnail in
                guard let self = self else { return }
                // Download video
                self.downloadVideo(from: url) { videoURL in
                    completion(videoURL, thumbnail)
                }
            }
        }
    }
    
    private func downloadVideo(from url: URL, completion: @escaping (URL?) -> Void) {
        let cacheFileURL = CacheUtils.videoCacheDirectory().appendingPathComponent(url.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: cacheFileURL.path) {
            videoCache.setObject(cacheFileURL as NSURL, forKey: url as NSURL)
            completion(cacheFileURL)
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, error in
            guard let self = self, let tempURL = tempURL, error == nil else {
                completion(nil)
                return
            }
            
            do {
                try FileManager.default.moveItem(at: tempURL, to: cacheFileURL)
                self.videoCache.setObject(cacheFileURL as NSURL, forKey: url as NSURL)
                completion(cacheFileURL)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func cacheVideo(from url: URL, completion: @escaping (URL?) -> Void) {
        let cacheFileURL = CacheUtils.videoCacheDirectory().appendingPathComponent(url.lastPathComponent)

        if FileManager.default.fileExists(atPath: cacheFileURL.path) {
            videoCache.setObject(cacheFileURL as NSURL, forKey: url as NSURL)
            completion(cacheFileURL)
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, error in
            guard let self = self, let tempURL = tempURL, error == nil else {
                completion(nil)
                return
            }

            do {
                try FileManager.default.moveItem(at: tempURL, to: cacheFileURL)
                self.videoCache.setObject(cacheFileURL as NSURL, forKey: url as NSURL)
                completion(cacheFileURL)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
    
    func cacheThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = thumbnailCache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            self.thumbnailCache.setObject(image, forKey: url as NSURL)
            completion(image)
        }
        task.resume()
    }
}


class CacheUtils {
    static func videoCacheDirectory() -> URL {
        let fileManager = FileManager.default
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let videoCacheDir = cacheDir.appendingPathComponent("VideoCache")

        if !fileManager.fileExists(atPath: videoCacheDir.path) {
            try? fileManager.createDirectory(at: videoCacheDir, withIntermediateDirectories: true, attributes: nil)
        }

        return videoCacheDir
    }
}

class ThumbnailCache {
    static let shared = NSCache<NSURL, UIImage>()
}
