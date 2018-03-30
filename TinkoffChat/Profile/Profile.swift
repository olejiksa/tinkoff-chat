//
//  Profile.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class Profile {
    var name: String?
    var about: String?
    var picture: UIImage?
    
    init() {}
    
    init(name: String?, about: String?, picture: UIImage?) {
        self.name = name;
        self.about = about;
        self.picture = picture;
    }
    
    class func read(filenames: (name: String, about: String, picture: String)) throws -> Profile? {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        
        var url = temporaryDirectory.appendingPathComponent(filenames.picture)
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        
        let picture = UIImage(contentsOfFile: url.path)
        
        url = temporaryDirectory.appendingPathComponent(filenames.name)
        let name = try String(contentsOf: url, encoding: .utf8)
        
        url = temporaryDirectory.appendingPathComponent(filenames.about)
        let about = try String(contentsOf: url, encoding: .utf8)
        
        return Profile(name: name, about: about, picture: picture)
    }
    
    class func write(_ profile: Profile, filenames: (name: String, about: String, picture: String)) throws {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
        
        var url = temporaryDirectory.appendingPathComponent(filenames.picture)
        if let picture = profile.picture {
            try UIImageJPEGRepresentation(picture, 1.0)?.write(to: url, options: .atomic)
        }
        
        url = temporaryDirectory.appendingPathComponent(filenames.name)
        try profile.name?.write(to: url, atomically: true, encoding: .utf8)
        
        url = temporaryDirectory.appendingPathComponent(filenames.about)
        try profile.about?.write(to: url, atomically: true, encoding: .utf8)
    }
}
