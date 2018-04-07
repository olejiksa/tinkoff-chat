//
//  SaveOperation.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class SaveOperation: Operation {
    typealias fileTuple = (name: String, about: String, picture: String)
    var profile: Profile
    var error: Error?
    var filenames: fileTuple
    
    init(profile: Profile, filenames: fileTuple) {
        self.profile = profile
        self.filenames = filenames
        super.init()
    }
    
    override func main() {
        do {
            try Profile.write(profile, filenames: filenames)
        } catch let error {
            self.error = error
        }
    }
}
