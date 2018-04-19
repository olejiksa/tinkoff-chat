//
//  AppUser
//  TinkoffChat
//
//  Created by Олег Самойлов on 08/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

extension AppUser {
    
    @nonobjc class func fetchRequest(model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
        let templateName = "AppUser"
        
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
            assert(false, "No template with name \(templateName)!")
            return nil
        }
        
        return fetchRequest
    }
    
    @nonobjc class func insert(in context: NSManagedObjectContext) -> AppUser? {
        return NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser
    }
    
    @nonobjc class func findOrInsert(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
            return nil
        }
        
        var profile: AppUser?
        guard let fetchRequest = fetchRequest(model: model) else {
            return nil
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count < 2, "Multiple users found!")
            if let foundProfile = results.first {
                profile = foundProfile
            }
        }
        catch {
            print("Failed to fetch user: \(error)")
        }
        
        if profile == nil {
            profile = insert(in: context)
        }
        
        return profile
    }
    
}
