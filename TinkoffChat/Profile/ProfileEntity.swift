//
//  ProfileEntity
//  TinkoffChat
//
//  Created by Олег Самойлов on 08/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

extension ProfileEntity {
    
    // MARK: - Core Data
    
    class func fetchRequest(model: NSManagedObjectModel) -> NSFetchRequest<ProfileEntity>? {
        let templateName = "ProfileFetchRequest"
        
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<ProfileEntity> else {
            assert(false, "No template with name \(templateName)!")
            return nil
        }
        
        return fetchRequest
    }
    
    class func insert(in context: NSManagedObjectContext) -> ProfileEntity? {
        return NSEntityDescription.insertNewObject(forEntityName: "ProfileEntity", into: context) as? ProfileEntity
    }
    
    class func findOrInsert(in context: NSManagedObjectContext) -> ProfileEntity? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
            return nil
        }
        
        var profile: ProfileEntity?
        guard let fetchRequest = fetchRequest(model: model) else {
            return nil
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple profiles found!")
            if let foundProfile = results.first {
                profile = foundProfile
            }
        }
        catch {
            print("Failed to fetch profile: \(error)")
        }
        
        if profile == nil {
            profile = insert(in: context)
        }
        
        return profile
    }
    
}
