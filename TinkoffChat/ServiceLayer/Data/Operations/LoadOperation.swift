//
//  LoadOperation.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

class LoadOperation: Operation {
    typealias FileTuple = (name: String, about: String, picture: String)
    var profile: IAppUser?
    var error: Error?
    var filenames: FileTuple
    
    private let filesManager: FilesManager
    
    init(filenames: FileTuple, filesManager: FilesManager) {
        self.filenames = filenames
        self.filesManager = filesManager
        super.init()
    }
    
    override func main() {
        do {
            profile = try filesManager.readProfile(filenames: filenames)
        } catch let error {
            self.error = error
        }
    }
}
