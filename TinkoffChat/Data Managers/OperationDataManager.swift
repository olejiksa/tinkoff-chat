//
//  OperationDataManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 30/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class OperationDataManager: DataManager {
    func loadProfile(completion: @escaping (Profile?, Error?) -> ()) {
        let load = LoadOperation(filenames: ("name.txt", "about.txt", "picture.jpg"))
        load.qualityOfService = .userInitiated
        load.completionBlock = {
            OperationQueue.main.addOperation {
                completion(load.profile, load.error)
            }
        }
        
        OperationQueue().addOperation(load)
    }
    
    func saveProfile(_ profile: Profile, completion: @escaping (Error?) -> ()) {
        let save = SaveOperation(profile: profile, filenames: ("name.txt", "about.txt", "picture.jpg"))
        save.qualityOfService = .userInitiated
        save.completionBlock = {
            OperationQueue.main.addOperation {
                completion(save.error)
            }
        }
        
        OperationQueue().addOperation(save)
    }
}
