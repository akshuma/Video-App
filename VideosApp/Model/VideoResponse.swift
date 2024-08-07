//
//  VideoResponse.swift
//  VideosApp
//
//  Created by Akshu on 04/08/24.
//

import Foundation

struct VideoResponse: Codable {
    let reels: [Reel]?
}

struct Reel: Codable {
    let arr: [VideoItem]
}

struct VideoItem: Codable {
    let id: String
    let video: URL
    let thumbnail: URL

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case video
        case thumbnail
    }
}
