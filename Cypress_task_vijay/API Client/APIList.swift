//
//  APIList.swift
//  infinite scroll
//
//  Created by Vijay on 13/05/22.
//

import Foundation

struct APIList
{
    private let Base_URL = "https://jsonplaceholder.typicode.com/"
    
    func getUrlString(for url: urlString) -> String {
        return Base_URL + url.rawValue
    }
}

enum urlString: String {
    case albums = "albums"
    case photos = "photos"
}
