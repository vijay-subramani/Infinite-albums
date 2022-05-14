//
//  AlbumListModel.swift
//  infinite scroll
//
//  Created by Vijay on 13/05/22.
//

import Foundation
import Realm
import RealmSwift

// MARK: - AlbumsListModelElement
struct AlbumsListModelElement: Codable {
    let userID, id: Int?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title
    }
}

typealias AlbumsListModel = [AlbumsListModelElement]


class AlbumObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var userId: Int = 0
}
