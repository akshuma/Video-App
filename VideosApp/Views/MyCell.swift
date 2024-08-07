import UIKit

class MyCell: UICollectionViewCell {
    static let identifier = "MyCell"
    
    private var videoViewModels: [VideoViewModel] = []
    private var isPlaying = false
    private let placeholderImage = UIImage(named: "placeholder")

    private let videoPlayerView1 = VideoPlayerView()
    private let videoPlayerView2 = VideoPlayerView()
    private let videoPlayerView3 = VideoPlayerView()
    private let videoPlayerView4 = VideoPlayerView()

    private var videoPlayerViews: [VideoPlayerView] {
        return [videoPlayerView1, videoPlayerView2, videoPlayerView3, videoPlayerView4]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let rowStackView1 = UIStackView(arrangedSubviews: [videoPlayerView1, videoPlayerView2])
        rowStackView1.axis = .horizontal
        rowStackView1.distribution = .fillEqually
        rowStackView1.spacing = 10

        let rowStackView2 = UIStackView(arrangedSubviews: [videoPlayerView3, videoPlayerView4])
        rowStackView2.axis = .horizontal
        rowStackView2.distribution = .fillEqually
        rowStackView2.spacing = 10

        let gridStackView = UIStackView(arrangedSubviews: [rowStackView1, rowStackView2])
        gridStackView.axis = .vertical
        gridStackView.distribution = .fillEqually
        gridStackView.spacing = 10
        gridStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(gridStackView)

        NSLayoutConstraint.activate([
            gridStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gridStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gridStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gridStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(with videoViewModels: [VideoViewModel]) {
        self.videoViewModels = videoViewModels
        setupVideoViews()
        playVideosSequentially()
    }

    private func setupVideoViews() {
        for (index, viewModel) in videoViewModels.enumerated() {
            if index < videoPlayerViews.count {
                let playerView = videoPlayerViews[index]
                loadThumbnail(for: viewModel, into: playerView)
            }
        }
    }

    private func loadThumbnail(for viewModel: VideoViewModel, into playerView: VideoPlayerView) {
        VideoManager.shared.cacheThumbnail(from: viewModel.thumbnailURL) { [weak self] image in
            DispatchQueue.main.async {
                if let image = image {
                    playerView.showThumbnail(image)
                } else {
                    playerView.showPlaceholder(self?.placeholderImage)
                }
            }
        }
    }

    private func playVideosSequentially() {
        guard !isPlaying, !videoViewModels.isEmpty else { return }

        let videoViewModelsToPlay = videoViewModels
        playNextVideo(in: videoViewModelsToPlay, currentIndex: 0)
    }

    private func playNextVideo(in viewModels: [VideoViewModel], currentIndex: Int) {
        guard currentIndex < viewModels.count else {
            isPlaying = false
            return
        }

        let viewModel = viewModels[currentIndex]
        guard let playerView = videoPlayerViews[safe: currentIndex] else { return }

        VideoManager.shared.cacheVideo(from: viewModel.videoURL) { [weak self] cachedURL in
            guard let self = self, let cachedURL = cachedURL else { return }

            DispatchQueue.main.async {
                playerView.playVideo(from: cachedURL) {
                    self.playNextVideo(in: viewModels, currentIndex: currentIndex + 1)
                }
                self.isPlaying = true
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        videoViewModels.removeAll()
        videoPlayerViews.forEach { $0.reset() }
        isPlaying = false
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
