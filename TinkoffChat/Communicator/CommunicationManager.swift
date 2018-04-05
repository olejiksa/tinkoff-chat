//
//  CommunicationManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 04/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class CommunicationManager: CommunicatorDelegate {
    var conversations = [[Conversation]]()
    
    init() {
        conversations.append([Conversation]())
        conversations.append([Conversation]())
        
        NotificationCenter.default.addObserver(self, selector: #selector(sortData), name: Notification.Name.ConversationsListSortData, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ConversationsListSortData, object: nil)
    }
    
    func didFoundUser(userID: String, userName: String?) {
        conversations[0].append(Conversation(id: userID,
                                             name: userName,
                                             messages: [Message](),
                                             lastMessageText: nil,
                                             date: nil,
                                             online: true,
                                             hasUnreadMessages: false))
        conversations[0].sort(by: Conversation.sortByDateAndName)
        
        // добавляем юзера в список диалогов
        NotificationCenter.default.post(name: Notification.Name.ConversationsListReloadData, object: nil)
    }
    
    func didLostUser(userID: String) {
        if let index = conversations[0].index(where: { (item) -> Bool in item.id == userID }) {
            conversations[0].remove(at: index)
            
            // удаляем юзера из списка диалогов, отключаем кнопку отправки
            NotificationCenter.default.post(name: Notification.Name.ConversationsListReloadData, object: nil)
            NotificationCenter.default.post(name: Notification.Name.ConversationTurnSendOff, object: nil)
        }
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print("Не удалось начать поиск пользователей")
    }
    
    func failedToStartAdvertising(error: Error) {
        print("Не удалось сделать устройство доступным для обнаружения")
    }
    
    func didReceiveMessage(text: String, fromUser: String, toUser: String) {
        if let index = conversations[0].index(where: { (item) -> Bool in item.id == fromUser }) {
            conversations[0][index].messages.insert(Message(messageText: text, isIncoming: true), at: 0)
            conversations[0][index].date = Date()
            conversations[0][index].lastMessageText = conversations[0][index].messages.first?.messageText
            conversations[0][index].hasUnreadMessages = true
            conversations[0].sort(by: Conversation.sortByDateAndName)
            
            // обновляются оба списка: нужно добавить сообщение в диалог и изменить lastMessageText
            NotificationCenter.default.post(name: Notification.Name.ConversationsListReloadData, object: nil)
            NotificationCenter.default.post(name: Notification.Name.ConversationReloadData, object: nil)
        }
    }
    
    @objc private func sortData() {
        conversations[0].sort(by: Conversation.sortByDateAndName)
    }
}
