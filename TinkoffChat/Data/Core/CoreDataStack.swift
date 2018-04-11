//
//  CoreDataStack.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 08/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    // MARK: - Model
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Storage", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // MARK: - Coordinator
    
    private var storeUrl: URL {
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentUrl.appendingPathComponent("Storage.sqlite")
    }
    
    lazy private var persistanceStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: storeUrl,
                                               options: options)
        }
        catch {
            print("\(error)")
        }
        
        return coordinator
    }()
    
    // MARK: - Contexts
    
    lazy var masterContext: NSManagedObjectContext = {
        var masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        masterContext.persistentStoreCoordinator = persistanceStoreCoordinator
        masterContext.mergePolicy = NSOverwriteMergePolicy
        
        return masterContext
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        mainContext.parent = masterContext
        mainContext.mergePolicy = NSOverwriteMergePolicy
        
        return mainContext
    }()
    
    lazy var saveContext: NSManagedObjectContext = {
        var saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        saveContext.parent = mainContext
        saveContext.mergePolicy = NSOverwriteMergePolicy
        
        return saveContext
    }()
    
    // MARK: - Save
    
    func performSave(context: NSManagedObjectContext, completion: @escaping (Error?) -> ()) {
        if context.hasChanges {
            context.perform { [weak self] in
                do {
                    try context.save()
                } catch {
                    print("\(error)")
                    completion(error)
                }
                
                if let parent = context.parent {
                    self?.performSave(context: parent, completion: completion)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
}
