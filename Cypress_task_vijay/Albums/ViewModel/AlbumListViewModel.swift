//
//  AlbumListViewModel.swift
//  Cypress_Interview_Task_Vijay
//
//  Created by Vijay on 13/05/22.
//

import Foundation
import UIKit
import RealmSwift
import SwiftUI

class AlbumListViewModel: NSObject
{
    
    let realm = try! Realm()
    
    private var albumsListService: AlbumsListServiceProtocol
    private var albumsPhotoService: AlbumPhotosServiceProtocol
    
    var albumList = AlbumsListModel()
    var albumPhotos = AlbumsPhotostModel()
    
    var reloadTableView: (() -> Void)?
    var reloadCollectionview: (() -> Void)?
    
    private let numberOfItems = 10000
    
    var AlbumCellViewModels = [AlbumCellViewModel]() {
        didSet {
            reloadTableView?()
        }
    }
    
    var AlbumsPhotoCellViewModels = [AlbumsPhotoCellViewModel]() {
        didSet {
            reloadCollectionview?()
        }
    }
    
    init(albumsListService: AlbumsListServiceProtocol = AlbumService(), albumsPhotoService: AlbumPhotosServiceProtocol = AlbumService()) {
        self.albumsListService = albumsListService
        self.albumsPhotoService = albumsPhotoService
    }
    
    func getAlbumList()
    {
        let albumsInDB = albumsListService.getAlbumsListFromDB()
        if albumsInDB.count > 0
        {
            debugPrint("///Loading data from realm db . . .")
            self.fetchAlbumListDataFromDB(albums: albumsInDB)
        }else
        {
            debugPrint("///Loading data from API . . .")
            albumsListService.getAlbumsList { albumlist in
                if let albums = albumlist {
                    self.fetchAlbumListData(albums: albums)
                }
            } failure: { error in
                print(error as Any)
            }
        }
    }
    
    func fetchAlbumListData(albums: AlbumsListModel)
    {
        self.albumList = albums //cache
        var albumData = [AlbumCellViewModel]()
        albumList.forEach { album in
            albumData.append(createCellModel(album: album))
        }
        AlbumCellViewModels = albumData
        albumsListService.insertAlbumsListToDB(albums: self.albumList)
    }
    
    func fetchAlbumListDataFromDB(albums: Results<AlbumObject>)
    {
        AlbumCellViewModels = []
        
        var albumListData = AlbumsListModel()
        albums.forEach { album in
            albumListData.append(AlbumsListModelElement.init(userID: album.userId, id: album.id, title: album.title))
        }
        self.albumList = albumListData
        
        var albumData = [AlbumCellViewModel]()
        albumList.forEach { album in
            albumData.append(createCellModel(album: album))
        }
        AlbumCellViewModels = albumData
    }
    
    func createCellModel(album: AlbumsListModelElement?) -> AlbumCellViewModel {
        let userID = album?.userID ?? 0
        let id = album?.id ?? 0
        let title = album?.title ?? ""
        return AlbumCellViewModel(userID: userID, id: id, title: title)
    }
    
    func getAlbumCellViewModel(at indexPath: IndexPath) -> AlbumCellViewModel {
        return AlbumCellViewModels[indexPath.row % AlbumCellViewModels.count]
    }
    
    func getAlbumListCellCount() -> Int
    {
        return AlbumCellViewModels.count > 0 ? numberOfItems : 0
    }
    
    func scrollToRow(tableView: UITableView) {
        if AlbumCellViewModels.count > 0
        {
            let indexPath = IndexPath(row: numberOfItems / 2, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    
}


extension AlbumListViewModel
{
    
    func cancelGettingPhotoList(albumId: Int)
    {
        albumsPhotoService.cancelDataTask(albumId: albumId)
    }
    
    func getAlbumsPhotoList(albumId: Int)
    {
        let albumPhotosInDB = albumsPhotoService.getAlbumPhotosFromDB()
        if albumPhotosInDB.filter({ $0.albumId == albumId}).count > 0 {
            debugPrint("///Loading Photos data from realm db . . .")
            self.fetchAlbumPhotoDataFromDB(photos: albumPhotosInDB, albumId: albumId)
        }else
        {
            debugPrint("///Loading Photos data from API . . .")
            albumsPhotoService.getAlbumPhotos(albumId:"\(albumId)") { albumPhotosList in
                if let albumPhotos = albumPhotosList {
                    self.fetchAlbumPhotosData(albumPhotos: albumPhotos, albumid: albumId)
                }
            } failure: { error in
                print(error as Any)
            }
        }
    }
    
    func fetchAlbumPhotosData(albumPhotos: AlbumsPhotostModel, albumid: Int) {
        self.albumPhotos = albumPhotos
        var photosData = [AlbumsPhotoCellViewModel]()
        albumPhotos.forEach { photo in
            photosData.append(createAlbumPhotoCellModel(albumPhotos: photo))
        }
        AlbumsPhotoCellViewModels = photosData
        albumsPhotoService.insertAlbumPhotosToDB(albumPhotos: albumPhotos, albumId: albumid)
    }
    
    func fetchAlbumPhotoDataFromDB(photos: Results<AlbumPhotoObject>, albumId: Int)
    {
        DispatchQueue.background(delay: 0.2, background: nil)
            { [weak self] in
                var albumPhotoData = AlbumsPhotostModel()
                photos.filter({ $0.albumId == albumId}).forEach { photo in
                    albumPhotoData.append(AlbumsPhotostModelElement.init(albumID: photo.albumId, id: photo.id, title: photo.title, url: photo.url, thumbnailURL: photo.thumbnail))
                }
                self?.albumPhotos = albumPhotoData
                var photoData = [AlbumsPhotoCellViewModel]()
                
                self?.albumPhotos.forEach { photo in
                    photoData.append(self!.createAlbumPhotoCellModel(albumPhotos: photo))
                }
                self?.AlbumsPhotoCellViewModels = []
                self?.AlbumsPhotoCellViewModels = photoData
            }
        
    }

    
    func createAlbumPhotoCellModel(albumPhotos: AlbumsPhotostModelElement?) -> AlbumsPhotoCellViewModel {
        let albumid = albumPhotos?.albumID ?? 0
        let id = albumPhotos?.id ?? 0
        let title = albumPhotos?.title ?? ""
        let url = albumPhotos?.url ?? ""
        let thumbnailUrl = albumPhotos?.thumbnailURL ?? ""
        return AlbumsPhotoCellViewModel(albumID: albumid, id: id, title: title, url: url, thumbnailURL: thumbnailUrl)
    }
    
    func getAlbumsPhotoCellViewModel(at indexPath: IndexPath) -> AlbumsPhotoCellViewModel {
        return AlbumsPhotoCellViewModels[indexPath.row % AlbumsPhotoCellViewModels.count]
    }
    
    func getAlbumsPhotoCellCount() -> Int {
        return AlbumsPhotoCellViewModels.count > 0 ? numberOfItems : 0
    }
    
    func scrollToItem(collectionView: UICollectionView) {
        if AlbumsPhotoCellViewModels.count > 0 {
            let indexPath = IndexPath(item: numberOfItems / 2, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
    }
}
