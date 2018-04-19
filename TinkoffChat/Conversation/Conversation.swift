//
//  Conversation.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 09/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

extension Conversation {
    
    @nonobjc class func withId(conversationId: String) -> Conversation? {
        guard let fetchRequest: NSFetchRequest<Conversation> = CoreDataService.shared.fetchRequest(.conversationWithId, substitutionDictionary: ["conversationId": conversationId]) else {
            return nil
        }
        
        let onlineSortDescriptor = NSSortDescriptor(key: "isOnline", ascending: false)
        let dateSortDescriptor = NSSortDescriptor(key: "lastMessage.date", ascending: false)
        let nameSortDescriptor = NSSortDescriptor(key: "interlocutor.name", ascending: true)
        fetchRequest.sortDescriptors = [onlineSortDescriptor, dateSortDescriptor, nameSortDescriptor]
        
        return CoreDataService.shared.fetch(fetchRequest)?.first
    }
    
}
