//
//  DownloadImageRequest.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 02/05/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

class DownloadImageRequest: IRequest {
    
    var urlString: String
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        return URLRequest(url: url)
    }
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
}
