//
//  DownloadImageParser.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 02/05/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation
import UIKit

class DownloadImageParser: IParser {
    
    typealias Model = UIImage
    
    func parse(data: Data) -> Model? {
        guard let image = UIImage(data: data) else { return nil }
        return image
    }
    
}
