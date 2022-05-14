//
//  Constants + Helper.swift
//  infinite scroll
//
//  Created by Vijay on 13/05/22.
//

import Foundation
import UIKit
import SDWebImage

class ImageLoader
{
    func imageLoad(imgView :UIImageView,url :String)
    {
        imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "placeHolder"))
    }
}
