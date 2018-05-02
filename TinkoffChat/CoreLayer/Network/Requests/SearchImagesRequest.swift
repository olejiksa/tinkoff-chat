//
//  SearchImagesRequest.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 02/05/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

class SearchImagesRequest: IRequest {
    
    private let key: String
    private let endpoint = "https://pixabay.com/api/"
    
    private var parameters = ["q": "yellow+flowers",
                              "image_type": "photo",
                              "pretty": "true",
                              "per_page": "200"]
    
    private var urlString: String {
        parameters["key"] = key
        
        var formingString = String()
        for pair in parameters {
            formingString.append("\(pair.key)=\(pair.value)&")
        }
        
        return String("\(endpoint)?\(formingString.dropLast())")
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        return URLRequest(url: url)
    }
    
    init(key: String) {
        self.key = key
    }
    
}
