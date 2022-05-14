//
//  AlbumPhotoCVCell.swift
//  Cypress_Interview_Task_Vijay
//
//  Created by Vijay on 13/05/22.
//

import UIKit

class AlbumPhotoCVCell: UICollectionViewCell {

    @IBOutlet weak var albumImg: UIImageView!
    
    var cellViewModel: AlbumsPhotoCellViewModel? {
        didSet {
            albumImg.layer.cornerRadius = 10
            ImageLoader().imageLoad(imgView: self.albumImg, url: cellViewModel?.url ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class var identifier: String
    {
        return String(describing: self)
    }
    
    class var nib: UINib
    {
        return UINib(nibName: identifier, bundle: nil)
    }

}
