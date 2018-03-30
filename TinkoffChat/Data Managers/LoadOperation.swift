//
//  LoadOperation.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class LoadOperation: Operation {
    var profile: Profile?
    var error: Error?
    var filenames: (name: String, about: String, picture: String)
    
    init(filenames: (name: String, about: String, picture: String)) {
        self.filenames = filenames
        super.init()
    }
    
    override func main() {
        do {
            profile = try Profile.read(filenames: filenames)
        } catch let error {
            self.error = error
        }
    }
}
