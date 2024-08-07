//
//  VideoPlayerView.swift
//  VideosApp
//
//  Created by Akshu on 04/08/24.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var player: AVPlayer?
    private let thumbnailImageView = UIImageView()
    private let placeholderImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        placeholderImageView.contentMode = .scaleAspectFill
        placeholderImageView.clipsToBounds = true
        addSubview(placeholderImageView)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderImageView.topAnchor.constraint(equalTo: topAnchor),
            placeholderImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholderImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeholderImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    func playVideo(from url: URL, completion: @escaping () -> Void) {
        VideoManager.shared.cacheVideo(from: url) { [weak self] cachedURL in
            guard let self = self, let videoURL = cachedURL else { return }
            DispatchQueue.main.async {
                self.player?.pause()
                self.player = AVPlayer(url: videoURL)
                self.player?.rate = 1.0

                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { _ in
                    completion()
                }

                self.playerLayer.player = self.player
                self.player?.seek(to: .zero)
                self.player?.play()

                self.thumbnailImageView.isHidden = true
                self.placeholderImageView.isHidden = true
            }
        }
    }

    func showThumbnail(_ image: UIImage?) {
        thumbnailImageView.image = image
        thumbnailImageView.isHidden = false
        placeholderImageView.isHidden = true
    }

    func showPlaceholder(_ image: UIImage?) {
        placeholderImageView.image = image
        placeholderImageView.isHidden = false
        thumbnailImageView.isHidden = true
    }

    func reset() {
        player?.pause()
        playerLayer.player = nil
        thumbnailImageView.image = nil
        placeholderImageView.image = nil
        thumbnailImageView.isHidden = true
        placeholderImageView.isHidden = true
    }
}
