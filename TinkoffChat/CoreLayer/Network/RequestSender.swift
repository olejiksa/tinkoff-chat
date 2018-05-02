//
//  RequestSender.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(String)
}

protocol IRequestSender {
    func send<Parser>(config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model>) -> ())
}

class RequestSender: IRequestSender {
    
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    func send<Parser>(config: RequestConfig<Parser>, completionHandler: @escaping (Result<Parser.Model>) -> ()) where Parser: IParser {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(.error("URL string cannot be parsed to URL"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(.error(error.localizedDescription))
                return
            }
            
            guard let data = data, let parsedModel: Parser.Model = config.parser.parse(data: data) else {
                completionHandler(.error("Received data cannot be parsed"))
                return
            }
            
            completionHandler(.success(parsedModel))
        }
        
        task.resume()
    }
    
}
