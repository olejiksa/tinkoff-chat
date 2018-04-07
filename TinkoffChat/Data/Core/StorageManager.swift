//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 08/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

class StorageManager: DataManager {
    
    private let coreDataStack = CoreDataStack()
    
    // MARK: - DataManager
    
    func loadProfile(completion: @escaping (Profile?, Error?) -> ()) {
        let loadContext = coreDataStack.loadContext
        
        loadContext.perform {
            guard let profileEntity = ProfileEntity.findOrInsert(in: loadContext) else {
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
                return
            }
            
            let profile = Profile()
            profile.name = profileEntity.name
            profile.about = profileEntity.about
            if let picture = profileEntity.picture {
                profile.picture = UIImage(data: picture)
            }
            
            DispatchQueue.main.async {
                completion(profile, nil)
            }
        }
    }
    
    func saveProfile(_ profile: Profile, completion: @escaping (Error?) -> ()) {
        let saveContext = coreDataStack.saveContext
        
        saveContext.perform {
            let profileEntity = ProfileEntity.findOrInsert(in: saveContext)
            profileEntity?.name = profile.name
            profileEntity?.about = profile.about
            
            if let picture = profile.picture {
                profileEntity?.picture = UIImageJPEGRepresentation(picture, 1.0)
            }
            
            self.coreDataStack.performSave(context: saveContext) { error in
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
}
