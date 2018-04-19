//
//  StorageManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 08/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class StorageManager: DataManager {
    
    private let coreDataStack = CoreDataStack()
    
    // MARK: - DataManager
    
    func loadProfile(completion: @escaping (Profile?, Error?) -> ()) {
        coreDataStack.mainContext.perform {
            guard let profileEntity = AppUser.findOrInsert(in: self.coreDataStack.mainContext) else {
                completion(nil, nil)
                return
            }
            
            let profile = Profile()
            profile.name = profileEntity.name
            profile.about = profileEntity.about
            if let picture = profileEntity.picture {
                profile.picture = UIImage(data: picture)
            }
            
            completion(profile, nil)
        }
    }
    
    func saveProfile(_ profile: Profile, completion: @escaping (Error?) -> ()) {
        coreDataStack.saveContext.perform {
            let profileEntity = AppUser.findOrInsert(in: self.coreDataStack.saveContext)
            profileEntity?.name = profile.name
            profileEntity?.about = profile.about
            
            if let picture = profile.picture {
                profileEntity?.picture = UIImageJPEGRepresentation(picture, 1.0)
            }
            
            self.coreDataStack.performSave(context: self.coreDataStack.saveContext) { error in
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
}
