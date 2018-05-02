//
//  RequestFactory.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

struct RequestFactory {
    
    struct PixabayRequests {
        
        private static let apiKey = "8874501-e863fe94814d693d0956a8585"
        
        static func searchImages() -> RequestConfig<SearchImagesParser> {
            let request = SearchImagesRequest(key: apiKey)
            let parser = SearchImagesParser()
            return RequestConfig<SearchImagesParser>(request: request, parser: parser)
        }
        
        static func downloadImage(urlString: String) -> RequestConfig<DownloadImageParser> {
            let request = DownloadImageRequest(urlString: urlString)
            let parser = DownloadImageParser()
            return RequestConfig<DownloadImageParser>(request: request, parser: parser)
        }
        
    }
    
}
