//
//  CoreDataManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 15/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData
import UIKit

protocol IDataManager: class {
    func loadAppUser(completion: @escaping (IAppUser?) -> ())
    func saveAppUser(_ profile: IAppUser, completion: @escaping (Bool) -> ())
    
    func appendConversation(id: String, userName: String)
    func makeConversationOffline(id: String)
    func readConversation(id: String)
    
    func appendMessage(text: String, conversationId: String, isIncoming: Bool)
}

// This thing is needed because FRC is used to retrieve data
// I know, it breaks SOA a little
// Thus, I applied it through the protocol usage
protocol ICoreDataStackBackdoor: class {
    // To avoid extra fields/functions, use CoreDataManager as IDataManager
    func fetchRequest<T>(_ fetchRequestName: String,
                         substitutionDictionary: [String: Any]?,
                         sortDescriptors: [NSSortDescriptor]?) -> NSFetchRequest<T>? where T: NSManagedObject
    var saveContext: NSManagedObjectContext { get }
}

class CoreDataManager: IDataManager, ICoreDataStackBackdoor {
    
    private let stack: ICoreDataStack
    
    init() {
        stack = CoreDataStack()
    }
    
    // MARK: - IDataManager
    
    func loadAppUser(completion: @escaping (IAppUser?) -> ()) {
        guard let profileEntity: AppUser = findOrInsert(entityName: "AppUser") else {
            completion(nil)
            return
        }
        
        let profile = Profile()
        profile.name = profileEntity.name
        profile.about = profileEntity.about
        if let picture = profileEntity.picture {
            profile.picture = UIImage(data: picture)
        }
        
        completion(profile)
    }
    
    func saveAppUser(_ profile: IAppUser, completion: @escaping (Bool) -> ()) {
        let profileEntity: AppUser? = findOrInsert(entityName: "AppUser")
        profileEntity?.name = profile.name
        profileEntity?.about = profile.about
        
        if let picture = profile.picture {
            profileEntity?.picture = UIImageJPEGRepresentation(picture, 1.0)
        }
        
        stack.performSave(context: stack.saveContext) { error in
            DispatchQueue.main.async {
                if error != nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func appendConversation(id: String, userName: String) {
        let conversation: Conversation? = withId(id, requestName: "ConversationWithId")
        guard conversation == nil else {
            conversation?.isOnline = true
            performSave()
            return
        }
        
        let user = NSEntityDescription.insertNewObject(forEntityName: "User",
                                                       into: stack.saveContext) as! User
        user.userId = id
        user.name = userName
        user.isOnline = true
        
        let chat = NSEntityDescription.insertNewObject(forEntityName: "Conversation",
                                                       into: stack.saveContext) as! Conversation
        chat.conversationId = id
        chat.hasUnreadMessages = false
        chat.interlocutor = user
        chat.appUser = nil
        chat.lastMessage = nil
        chat.isOnline = true
        
        user.addToConversations(chat)
        
        performSave()
    }
    
    func makeConversationOffline(id: String) {
        guard let user: User = withId(id, requestName: "UserWithId"),
              let conversation: Conversation = withId(id, requestName: "ConversationWithId")
              else { return }
        
        if conversation.lastMessage != nil {
            conversation.isOnline = false
        } else {
            stack.saveContext.delete(conversation)
            stack.saveContext.delete(user)
        }
        
        performSave()
    }
    
    func readConversation(id: String) {
        guard let conversation: Conversation = withId(id, requestName: "ConversationWithId")
            else { return }
        
        conversation.hasUnreadMessages = false
        performSave()
    }
    
    func appendMessage(text: String, conversationId: String, isIncoming: Bool) {
        guard let conversation: Conversation = withId(conversationId, requestName: "ConversationWithId")
            else { return }
        
        let message: Message = NSEntityDescription.insertNewObject(forEntityName: "Message",
                                                                   into: stack.saveContext) as! Message
        message.messageId = Message.generateMessageId()
        message.date = Date()
        message.isIncoming = isIncoming
        message.messageText = text
        message.conversation = conversation
        message.lastMessageInConversation = conversation
        
        conversation.hasUnreadMessages = isIncoming
        
        performSave()
    }
    
    // MARK: - Helpers
    
    private func performSave() {
        stack.performSave(context: stack.saveContext) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    private func withId<T>(_ id: String, requestName: String) -> T? where T: NSManagedObject {
        guard let request: NSFetchRequest<T> =
              fetchRequest(requestName, substitutionDictionary: ["id": id]),
              let first = try? stack.saveContext.fetch(request).first else { return nil }
        
        return first
    }
    
    private func findOrInsert<T>(entityName: String) -> T? where T: NSManagedObject {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: entityName)
        
        guard var object = try? stack.saveContext.fetch(request).first else {
            return nil
        }
        
        if object == nil {
            object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: stack.mainContext) as? T
        }
        
        return object
    }
    
    func fetchRequest<T>(_ fetchRequestName: String,
                         substitutionDictionary: [String: Any]? = nil,
                         sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<T>? where T: NSManagedObject {
        let request: NSFetchRequest<T>?
        
        request = substitutionDictionary == nil ?
            stack.managedObjectModel.fetchRequestTemplate(forName: fetchRequestName) as? NSFetchRequest<T> :
            stack.managedObjectModel.fetchRequestFromTemplate(withName: fetchRequestName, substitutionVariables: substitutionDictionary!) as? NSFetchRequest<T>
        request?.sortDescriptors = sortDescriptors
        
        guard request != nil else {
            assert(false, "No template with name \(fetchRequestName)!")
            return nil
        }
        
        return request
    }
    
    // MARK: - ICoreDataStackBackdoor
    
    var saveContext: NSManagedObjectContext {
        return stack.saveContext
    }
    
}
