//
//  PicturesModel.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

struct Picture: Codable {
    let previewUrl: String
    let largeImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case previewUrl = "previewURL"
        case largeImageUrl = "largeImageURL"
    }
}

protocol IPicturesModel: class {
    var data: [Picture] { get set }
    
    func fetchAllPictures(completionHandler: @escaping ([Picture]?, String?) -> ())
    func fetchPicture(urlString: String, completionHandler: @escaping (UIImage?) -> ())
}

class PicturesModel: IPicturesModel {
    
    private let picturesService: IPicturesService
    
    var data: [Picture] = []
    
    init(picturesService: IPicturesService) {
        self.picturesService = picturesService
    }
    
    func fetchAllPictures(completionHandler: @escaping ([Picture]?, String?) -> ()) {
        picturesService.getPictures { pictures, errorText in
            guard let pictures = pictures else {
                completionHandler(nil, errorText)
                return
            }
            
            completionHandler(pictures, nil)
        }
    }
    
    func fetchPicture(urlString: String, completionHandler: @escaping (UIImage?) -> ()) {
        picturesService.downloadPicture(urlString: urlString) { image, error in
            guard let image = image else { return completionHandler(nil) }
            completionHandler(image)
        }
    }
    
}
