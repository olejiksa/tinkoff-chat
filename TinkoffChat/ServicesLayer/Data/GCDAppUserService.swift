//
//  GCDAppUserService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

protocol IAppUserService: class {
    func loadAppUser(completion: @escaping (IAppUser?) -> ())
    func saveAppUser(_ profile: IAppUser, completion: @escaping (Bool) -> ())
}

class GCDAppUserService: IAppUserService {
    
    private let fileManager: FilesManager
    
    init(fileManager: FilesManager) {
        self.fileManager = fileManager
    }
    
    // MARK: - IAppUserService
    
    func loadAppUser(completion: @escaping (IAppUser?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let profile = try self.fileManager.readProfile(filenames: (name: "name.txt", about: "about.txt", picture: "picture.jpg"))

                DispatchQueue.main.async {
                    completion(profile)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func saveAppUser(_ profile: IAppUser, completion: @escaping (Bool) -> ()) {
        DispatchQueue(label: "com.olejiksa.customSerial", qos: .userInitiated).async {
            do {
                try self.fileManager.writeProfile(profile, filenames: (name: "name.txt",
                                                                       about: "about.txt",
                                                                       picture: "picture.jpg"))
                DispatchQueue.main.async {
                    completion(false)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
    }
    
}
