//
//  OperationAppUserService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

class OperationAppUserService: IAppUserService {
    
    private let filesManager = FilesManager()
    
    // MARK: - IDataService
    
    func loadAppUser(completion: @escaping (IAppUser?) -> ()) {
        let load = LoadOperation(filenames: ("name.txt", "about.txt", "picture.jpg"),
                                 filesManager: filesManager)
        load.qualityOfService = .userInitiated
        load.completionBlock = {
            OperationQueue.main.addOperation {
                completion(load.profile)
            }
        }
        
        OperationQueue().addOperation(load)
    }
    
    func saveAppUser(_ profile: IAppUser, completion: @escaping (Bool) -> ()) {
        let save = SaveOperation(profile: profile, filenames: ("name.txt", "about.txt", "picture.jpg"),
                                 filesManager: filesManager)
        save.qualityOfService = .userInitiated
        save.completionBlock = {
            OperationQueue.main.addOperation {
                if save.error != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        
        let userOperationQueue = OperationQueue()
        userOperationQueue.maxConcurrentOperationCount = 1
        userOperationQueue.addOperation(save)
    }
    
}
