//
//  FRCService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 26/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

protocol IFRCService: class {
    func allConversations() -> NSFetchRequest<Conversation>
    func messagesInConversation(with id: String) -> NSFetchRequest<Message>
    var saveContext: NSManagedObjectContext { get }
}

class FRCService: IFRCService {
    
    private let backdoor: ICoreDataStackBackdoor
    
    init(backdoor: ICoreDataStackBackdoor) {
        self.backdoor = backdoor
    }
    
    func allConversations() -> NSFetchRequest<Conversation> {
        let fetchRequest = NSFetchRequest<Conversation>(entityName: "Conversation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "isOnline", ascending: false),
                                        NSSortDescriptor(key: "lastMessage.date", ascending: false),
                                        NSSortDescriptor(key: "interlocutor.name", ascending: true)]
        
        return fetchRequest
    }
    
    func messagesInConversation(with id: String) -> NSFetchRequest<Message> {
        let fetchRequest: NSFetchRequest<Message>? = backdoor.fetchRequest("MessagesInConversation", substitutionDictionary: ["id": id], sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
        
        if fetchRequest != nil {
            return fetchRequest!
        } else {
            fatalError("Cannot use MessagesInConversation fetch request template")
        }
    }
    
    var saveContext: NSManagedObjectContext {
        return backdoor.saveContext
    }
    
}
