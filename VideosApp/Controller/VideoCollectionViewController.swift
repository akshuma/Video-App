//
//  VideoCollectionViewController.swift
//  VideosApp
//
//  Created by Akshu on 04/08/24.
//

import Foundation
import UIKit

class VideoCollectionViewController: UICollectionViewController, VideoViewModelDelegate {
    private var viewModel: VideoCollectionViewModelProtocol

    init(viewModel: VideoCollectionViewModelProtocol, layout: UICollectionViewLayout) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(MyCell.self, forCellWithReuseIdentifier: "MyCell")
        collectionView.collectionViewLayout = createLayout()
        viewModel.delegate = self
        viewModel.fetchVideoData()
    }

    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
           layout.itemSize = CGSize(width: view.frame.width, height: 600) // Adjust height as needed
           layout.minimumLineSpacing = 10 // Adjust spacing as needed
           layout.minimumInteritemSpacing = 10 // Adjust spacing as needed
           return layout
    }

    func didUpdateVideoItems() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    func didFailWithError(error: Error) {
        print("Error fetching video data: \(error.localizedDescription)")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel.videoItems.count + 3) / 4
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! MyCell
        let startIndex = indexPath.item * 4
        let endIndex = min(startIndex + 4, viewModel.videoItems.count)
        let itemsForCell = Array(viewModel.videoItems[startIndex..<endIndex])
        let itemViewModels = itemsForCell.map { VideoViewModel(videoItem: $0) }
        cell.configure(with: itemViewModels)
        cell.backgroundColor = .gray
        return cell
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleCells = collectionView.visibleCells.compactMap { $0 as? MyCell }
        for cell in visibleCells {
           // cell.playNextVideo()
        }
    }
}
