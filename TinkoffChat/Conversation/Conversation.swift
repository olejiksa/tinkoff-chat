//
//  ConversationModel.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 09/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

class Conversation: ConversationCellConfiguration {
    var id: String
    var name: String?
    var messages: [Message]
    var lastMessageText: String?
    var date: Date?
    var online: Bool
    var hasUnreadMessages: Bool
    
    init(id: String,
         name: String?,
         messages: [Message],
         lastMessageText: String?,
         date: Date?, online: Bool,
         hasUnreadMessages: Bool) {
        self.id = id
        self.name = name
        self.messages = messages
        self.lastMessageText = lastMessageText
        self.date = date
        self.online = online
        self.hasUnreadMessages = hasUnreadMessages
    }
    
    class func sortByDateAndName(c1: Conversation, c2: Conversation) -> Bool {
        if let first = c1.date, let second = c2.date {
            // чем свежее дата, тем выше
            return first > second
        } else if c1.date != c2.date && (c1.date == nil || c2.date == nil) {
            /* применяется для сортировки объектов, для которых дата есть лишь у одного из них,
             * объект с датой идет вверх */
            return c1.date ?? Date.distantPast > c2.date ?? Date.distantPast
        } else if let first = c1.name, let second = c2.name {
            // чем меньше первый несовпадающий символ имени, тем выше
            return first < second
        }
        
        return true
    }
}
