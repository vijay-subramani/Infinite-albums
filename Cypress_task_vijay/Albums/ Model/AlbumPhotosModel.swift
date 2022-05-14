//
//  AlbumPhotosModel.swift
//  infinite scroll
//
//  Created by Vijay on 13/05/22.
//

import Foundation
import RealmSwift

// MARK: - AlbumsPhotostModelElement
struct AlbumsPhotostModelElement: Codable {
    let albumID, id: Int?
    let title: String?
    let url, thumbnailURL: String?

    enum CodingKeys: String, CodingKey {
        case albumID = "albumId"
        case id, title, url
        case thumbnailURL = "thumbnailUrl"
    }
}

typealias AlbumsPhotostModel = [AlbumsPhotostModelElement]

class AlbumPhotoObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var url: String = ""
    @objc dynamic var thumbnail: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var albumId: Int = 0
}
