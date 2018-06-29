//
//  SaveOperation.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

class SaveOperation: Operation {
    typealias FileTuple = (name: String, about: String, picture: String)
    var profile: IAppUser
    var error: Error?
    var filenames: FileTuple
    
    private let filesManager: FilesManager
    
    init(profile: IAppUser, filenames: FileTuple, filesManager: FilesManager) {
        self.profile = profile
        self.filenames = filenames
        self.filesManager = filesManager
        
        super.init()
    }
    
    override func main() {
        do {
            try filesManager.writeProfile(profile, filenames: filenames)
        } catch let error {
            self.error = error
        }
    }
}
