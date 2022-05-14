//
//  Extensions.swift
//  infinite scroll
//
//  Created by Vijay on 12/05/22.
//

import Foundation
import UIKit


//MARK: - UITableView
extension UITableView{
    func dequeue<T>(_ identifier :String, _ OfClass :T.Type) -> T{
        var cell = self.dequeueReusableCell(withIdentifier: identifier) as? T
        if cell == nil{
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
            cell = self.dequeueReusableCell(withIdentifier: identifier) as? T
        }
        return cell!
    }
}

//MARK: - UICollectionView
extension UICollectionView{
    
    func dequeueXib<T>(_ identifier :String, _ indexPath:IndexPath, _ OfClass :T.Type) -> T{
        self.register(UINib(nibName: identifier, bundle:nil), forCellWithReuseIdentifier: identifier)
        let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T
        return cell!
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
