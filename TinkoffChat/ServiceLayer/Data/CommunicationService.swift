//
//  CommunicationService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 04/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

protocol ICommunicatorDelegate: class {
    var communicator: ICommunicator { get }
    
    // discovering
    func didFindUser(id: String, name: String)
    func didLoseUser(id: String)
    
    // errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    // messages
    func didReceiveMessage(text: String, from user: String)
    func didSendMessage(text: String, to user: String)
    
    func didConversationRead(id: String)
}

class CommunicationService: ICommunicatorDelegate {
    
    private let dataManager: IDataManager
    var communicator: ICommunicator
        
    init(dataManager: IDataManager, communicator: ICommunicator) {
        self.dataManager = dataManager
        self.communicator = communicator
        
        communicator.delegate = self
    }
    
    func didFindUser(id: String, name: String) {
        dataManager.appendConversation(id: id, userName: name)
    }
    
    func didLoseUser(id: String) {
        dataManager.makeConversationOffline(id: id)
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        print("Не удалось начать поиск пользователей")
    }
    
    func failedToStartAdvertising(error: Error) {
        print("Не удалось сделать устройство доступным для обнаружения")
    }
    
    func didReceiveMessage(text: String, from user: String) {
        dataManager.appendMessage(text: text, conversationId: user, isIncoming: true)
    }
    
    func didSendMessage(text: String, to user: String) {
        dataManager.appendMessage(text: text, conversationId: user, isIncoming: false)
    }
    
    func didConversationRead(id: String) {
        dataManager.readConversation(id: id)
    }
    
}
