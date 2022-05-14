//
//  APIConnection.swift
//  Cypress_Interview_Task_Vijay
//
//  Created by Vijay on 13/05/22.
//

import Foundation
import RealmSwift

protocol AlbumsListServiceProtocol {
    func getAlbumsList(success: @escaping (AlbumsListModel?)->Void, failure: @escaping (Error?)->Void)
    func getAlbumsListFromDB() -> Results<AlbumObject>
    func insertAlbumsListToDB(albums: AlbumsListModel)
}


protocol AlbumPhotosServiceProtocol {
    func getAlbumPhotos(albumId:String, success: @escaping (AlbumsPhotostModel?)->Void, failure: @escaping (Error?)->Void)
    func getAlbumPhotosFromDB() -> Results<AlbumPhotoObject>
    func insertAlbumPhotosToDB(albumPhotos: AlbumsPhotostModel, albumId: Int)
}

class AlbumService: AlbumsListServiceProtocol, AlbumPhotosServiceProtocol {
    
    
    let realm = try! Realm()
    
    func getAlbumsList(success: @escaping (AlbumsListModel?) -> Void, failure: @escaping (Error?) -> Void) {
        HttpRequestHelper().GET(url: APIList().getUrlString(for: .albums), params: ["" : ""], httpHeader: .application_json) { (JSON) in
            do {
                let model = try JSONDecoder().decode(AlbumsListModel.self, from: JSON)
                success(model)
            } catch {
                let errorMsg = "Error: Trying to parse AlbumsList to model"
                let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey : errorMsg])
                failure(error)
            }
        } failure: { (error) in
            
        }

    }
    
    func getAlbumsListFromDB() -> Results<AlbumObject>
    {
        let albumListObject = try self.realm.objects(AlbumObject.self)
        debugPrint("album data available in database. albumcount: \(albumListObject.count)")
        return albumListObject
        
    }
    
    func insertAlbumsListToDB(albums: AlbumsListModel) {
        DispatchQueue.main.async {
            if albums.count > self.getAlbumsListFromDB().count
            {
                self.realm.beginWrite()
                self.realm.delete(self.realm.objects(AlbumObject.self))
                try! self.realm.commitWrite()
            }
            debugPrint("///Inserting data to realm db . . .")
            for album in albums {
                let albumData = AlbumObject()
                albumData.id = album.id ?? 0
                albumData.userId = album.userID ?? 0
                albumData.title = album.title ?? ""
                
                self.realm.beginWrite()
                self.realm.add(albumData)
                try! self.realm.commitWrite()
            }
            
        }
    }
    
    
    func getAlbumPhotos(albumId:String, success: @escaping (AlbumsPhotostModel?) -> Void, failure: @escaping (Error?) -> Void) {
        HttpRequestHelper().GET(url: APIList().getUrlString(for: .photos) + "?albumId=\(albumId)", params: ["" : ""], httpHeader: .application_json) { (JSON) in
            do {
                let model = try JSONDecoder().decode(AlbumsPhotostModel.self, from: JSON)
                success(model)
            } catch {
                let errorMsg = "Error: Trying to parse AlbumsPhotosList to model"
                let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey : errorMsg])
                failure(error)
            }
        } failure: { (error) in
            
            
        }
    }
    
    
    func getAlbumPhotosFromDB() -> Results<AlbumPhotoObject>
    {
        let albumPhotoObject = try realm.objects(AlbumPhotoObject.self)
        debugPrint("album data available in database. albumcount: \(albumPhotoObject.count)")
        return albumPhotoObject
    }
    
    func insertAlbumPhotosToDB(albumPhotos: AlbumsPhotostModel, albumId: Int) {
        DispatchQueue.main.async {
            let photos = self.getAlbumPhotosFromDB().filter { $0.albumId == albumId}
            if albumPhotos.count > photos.count
            {
                self.realm.beginWrite()
                self.realm.delete(photos)
                try! self.realm.commitWrite()
            }
            debugPrint("///Inserting photos data to realm db . . .")
            var albumPhotoObjects = [AlbumPhotoObject]()
            for photo in albumPhotos {
                let albumPhoto = AlbumPhotoObject()
                albumPhoto.id = photo.id ?? 0
                albumPhoto.title = photo.title ?? ""
                albumPhoto.thumbnail = photo.thumbnailURL ?? ""
                albumPhoto.url = photo.url ?? ""
                albumPhoto.albumId = photo.albumID ?? 0
                albumPhotoObjects.append(albumPhoto)
            }
            self.realm.beginWrite()
            self.realm.add(albumPhotoObjects)
            try! self.realm.commitWrite()
        }
    }
}
