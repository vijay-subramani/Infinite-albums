//
//  AlbumTVCell.swift
//  Cypress_Interview_Task_Vijay
//
//  Created by Vijay on 13/05/22.
//

import UIKit

class AlbumTVCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }

    @IBOutlet weak var albumTitleLbl: UILabel!
    @IBOutlet weak var albumPhotoCollection: UICollectionView!
    
    lazy var viewModel = {
        AlbumListViewModel()
    }()
    var albumId = Int()
    
    var cellViewModel: AlbumCellViewModel? {
        didSet {
            albumTitleLbl.text = cellViewModel?.title ?? ""
            albumId = cellViewModel?.id ?? 0
            initView()
            initViewModel()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initView()
    {
        albumPhotoCollection.delegate = self
        albumPhotoCollection.dataSource = self
        albumPhotoCollection.layoutIfNeeded()
        albumPhotoCollection.prefetchDataSource = self
        albumPhotoCollection.allowsSelection = false
        albumPhotoCollection.showsHorizontalScrollIndicator = false
    }
    
    func initViewModel()
    {
        viewModel.getAlbumsPhotoList(albumId: self.albumId)
        viewModel.reloadCollectionview = {
            DispatchQueue.main.async {
                self.albumPhotoCollection.reloadData()
                self.viewModel.scrollToItem(collectionView: self.albumPhotoCollection)
            }
        }
    }
    
}


extension AlbumTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}


extension AlbumTVCell: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getAlbumsPhotoCellCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueXib(AlbumPhotoCVCell.identifier, indexPath, AlbumPhotoCVCell.self)
        let cellVM = viewModel.getAlbumsPhotoCellViewModel(at: indexPath)
        cell.cellViewModel = cellVM
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexpath in
            let cell = collectionView.dequeueXib(AlbumPhotoCVCell.identifier, indexpath, AlbumPhotoCVCell.self)
            let cellVM = viewModel.getAlbumsPhotoCellViewModel(at: indexpath)
            cell.cellViewModel = cellVM
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexpath in
            viewModel.cancelGettingPhotoList(albumId: self.albumId)
        }
    }
}
