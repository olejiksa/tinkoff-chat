//
//  PictureCell.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IPictureCellConfiguration {
    var previewUrl: String? { get set }
    var largeImageUrl: String? { get set }
}

class PictureCell: UICollectionViewCell, IPictureCellConfiguration {
    
    var previewUrl, largeImageUrl: String?
    
    @IBOutlet var imageView: UIImageView!
    
    func setup(image: UIImage, picture: Picture) {
        imageView.image = image
        
        previewUrl = picture.previewUrl
        largeImageUrl = picture.largeImageUrl
    }
    
}
