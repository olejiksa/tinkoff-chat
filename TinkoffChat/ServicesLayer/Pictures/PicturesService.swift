//
//  PicturesService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IPicturesService {
    func getPictures(completionHandler: @escaping ([Picture]?, String?) -> ())
    func downloadPicture(urlString: String, completionHandler: @escaping (UIImage?, String?) -> ())
}

class PicturesService: IPicturesService {
    
    private let requestSender: IRequestSender
    
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    
    func getPictures(completionHandler: @escaping ([Picture]?, String?) -> Void) {
        let requestConfig = RequestFactory.PixabayRequests.searchImages()
        
        requestSender.send(config: requestConfig) { (result: Result<[Picture]>) in
            switch result {
            case .success(let pictures):
                completionHandler(pictures, nil)
            case .error(let error):
                completionHandler(nil, error)
            }
        }
    }
    
    func downloadPicture(urlString: String, completionHandler: @escaping (UIImage?, String?) -> ()) {
        let requestConfig = RequestFactory.PixabayRequests.downloadImage(urlString: urlString)
        
        requestSender.send(config: requestConfig) { (result: Result<UIImage>) in
            switch result {
            case .success(let picture):
                completionHandler(picture, nil)
            case .error(let error):
                completionHandler(nil, error)
            }
        }
    }
    
}
