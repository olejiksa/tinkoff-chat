//
//  CommunicationManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 04/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

class CommunicationManager: CommunicatorDelegate {
    
    func didFoundUser(userID: String, userName: String?) {
        let conversation = Conversation.withId(conversationId: userID)
        guard conversation == nil else {
            conversation?.isOnline = true
            CoreDataService.shared.save()
            return
        }
        
        let user: User = CoreDataService.shared.add(.user)
        user.userId = userID
        user.name = userName
        user.isOnline = true
        
        let chat: Conversation = CoreDataService.shared.add(.conversation)
        chat.conversationId = userID
        chat.hasUnreadMessages = false
        chat.interlocutor = user
        chat.appUser = nil
        chat.lastMessage = nil
        chat.isOnline = true
        
        user.addToConversations(chat)
        
        CoreDataService.shared.save()
    }
    
    func didLostUser(userID: String) {
        guard let user = User.withId(userId: userID),
            let conversation = Conversation.withId(conversationId: userID)
            else { return }
        
        if conversation.lastMessage != nil {
            conversation.isOnline = false
        } else {
            CoreDataService.shared.delete(conversation)
            CoreDataService.shared.delete(user)
        }
        
        CoreDataService.shared.save()
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print("Не удалось начать поиск пользователей")
    }
    
    func failedToStartAdvertising(error: Error) {
        print("Не удалось сделать устройство доступным для обнаружения")
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        guard let conversation = Conversation.withId(conversationId: fromUser)
            else { return }
        
        let message: Message = CoreDataService.shared.add(.message)
        message.messageId = Message.generateMessageId()
        message.date = Date()
        message.isIncoming = true
        message.messageText = text
        message.conversation = conversation
        message.lastMessageInConversation = conversation
        
        conversation.hasUnreadMessages = true
        
        CoreDataService.shared.save()
    }
    
}
