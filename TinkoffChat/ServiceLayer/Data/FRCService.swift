//
//  FRCService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 26/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

protocol IFRCService: class {
    func allConversations() -> NSFetchRequest<Conversation>?
    func messagesInConversation(with id: String) -> NSFetchRequest<Message>?
    
    var saveContext: NSManagedObjectContext { get }
}

class FRCService: IFRCService {
    
    private let backdoor: ICoreDataStackBackdoor
    
    init(backdoor: ICoreDataStackBackdoor) {
        self.backdoor = backdoor
    }
    
    func allConversations() -> NSFetchRequest<Conversation>? {
        let online = NSSortDescriptor(key: "isOnline", ascending: false)
        let date = NSSortDescriptor(key: "lastMessage.date", ascending: false)
        let name = NSSortDescriptor(key: "interlocutor.name", ascending: true)
        
        
        let fr = NSFetchRequest<Conversation>(entityName: "Conversation")
        fr.sortDescriptors = [online, date, name]
        
        return fr
    }
    
    func messagesInConversation(with id: String) -> NSFetchRequest<Message>? {
        return backdoor.fetchRequest("MessagesInConversation",
                                     substitutionDictionary: ["id": id],
                                     sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
    }
    
    var saveContext: NSManagedObjectContext {
        return backdoor.saveContext
    }
    
}
