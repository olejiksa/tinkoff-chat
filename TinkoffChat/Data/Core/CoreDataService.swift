//
//  CoreDataService
//  TinkoffChat
//
//  Created by Олег Самойлов on 15/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

class CoreDataService {
    
    static let shared = CoreDataService()
    
    private init() {}
    
    var coreDataStack = CoreDataStack()
    
    func add<T>(_ entity: EntityType) -> T where T: NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: entity.rawValue, into: coreDataStack.saveContext) as! T
    }
    
    func delete<T>(_ element: T) where T: NSManagedObject {
        coreDataStack.saveContext.delete(element)
    }
    
    func fetch<T>(_ request: NSFetchRequest<T>) -> [T]? where T: NSManagedObject {
        return try? coreDataStack.saveContext.fetch(request)
    }
    
    func save() {
        coreDataStack.performSave(context: coreDataStack.saveContext) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    // MARK: - NSFetchRequest
    
    func getAll<T>(_ entity: EntityType) -> NSFetchRequest<T> where T: NSManagedObject {
        return NSFetchRequest<T>(entityName: entity.rawValue)
    }
    
    func fetchRequest<T>(_ fetchRequest: FetchRequestKind, substitutionDictionary: [String: Any]? = nil) -> NSFetchRequest<T>? where T: NSManagedObject {
        let request: NSFetchRequest<T>?
        
        if substitutionDictionary == nil {
            request = coreDataStack.managedObjectModel.fetchRequestTemplate(forName: fetchRequest.rawValue) as? NSFetchRequest<T>
        } else {
            request = coreDataStack.managedObjectModel.fetchRequestFromTemplate(withName: fetchRequest.rawValue, substitutionVariables: substitutionDictionary!) as? NSFetchRequest<T>
        }
        
        guard request != nil else {
            assert(false, "No template with name \(fetchRequest.rawValue)!")
            return nil
        }
        
        return request
    }
    
    // MARK: - NSFetchedResultsController
    
    func setupFRC<T>(_ fetchRequest: NSFetchRequest<T>, fetchResultManager: FetchedResultsManager, sectionNameKeyPath: String? = nil) -> NSFetchedResultsController<T> where T: NSManagedObject {
        let fetchedResultsController = NSFetchedResultsController<T>(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.saveContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        fetchedResultsController.delegate = fetchResultManager
        
        return fetchedResultsController
    }
    
    func fetchData<T>(_ fetchedResultController: NSFetchedResultsController<T>) where T: NSManagedObject {
        coreDataStack.saveContext.perform {
            do {
                try fetchedResultController.performFetch()
            } catch {
                print()
            }
        }
    }
    
    // MARK: - Enums
    
    enum EntityType: String {
        case conversation = "Conversation"
        case message = "Message"
        case user = "User"
    }
    
    enum FetchRequestKind: String {
        case conversationWithId = "ConversationWithId"
        case messagesInConversation = "MessagesInConversation"
        case userWithId = "UserWithId"
        // add others if needed...
    }
    
    enum SortDescriptorKind: String {
        case conversationId = "conversationId"
        case messageId = "messageId"
        case userId = "userId"
    }
    
}
