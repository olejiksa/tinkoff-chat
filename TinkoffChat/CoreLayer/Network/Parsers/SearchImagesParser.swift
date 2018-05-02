//
//  SearchImagesParser.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 02/05/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

struct Response: Codable {
    let hits: [Picture]
}

class SearchImagesParser: IParser {
    typealias Model = [Picture]
    
    func parse(data: Data) -> Model? {
        do {
            return try JSONDecoder().decode(Response.self, from: data).hits
        } catch  {
            print("Error trying to convert data to JSON")
            return nil
        }
    }
}
