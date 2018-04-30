//
//  ConversationModel.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 24/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IConversationModel: IKeyboardModel {
    var conversation: Conversation { get set }
    var dataProvider: MessagesDataProvider? { get set }
    
    var frcService: IFRCService { get set }
    
    func makeRead()
}

class ConversationModel: IConversationModel {
    
    var conversation: Conversation
    var dataProvider: MessagesDataProvider?
    
    private var keyboardService: IKeyboardService
    private var communicationService: ICommunicatorDelegate
    var frcService: IFRCService
    
    init(communicationService: ICommunicatorDelegate,
         frcService: IFRCService,
         keyboardService: IKeyboardService,
         conversation: Conversation) {
        self.communicationService = communicationService
        self.keyboardService = keyboardService
        self.conversation = conversation
        self.frcService = frcService
    }
    
    func makeRead() {
        guard let id = conversation.conversationId else { return }
        communicationService.didConversationRead(id: id)
    }
    
    // MARK: - IKeyboardService
    
    func setKeyboardDelegate(_ delegate: UIView?) {
        keyboardService.delegate = delegate
    }
    
    func turnKeyboard(on: Bool) {
        keyboardService.turnKeyboard(on: on)
    }
    
    // MARK: - ICommunicatorDelegate
    
    enum SendMessageResult {
        case success
        case error(String?)
    }
    
    func sendMessage(text: String, receiver: String, completionHandler: (SendMessageResult) -> ()) {
        communicationService.communicator.sendMessage(text: text, to: receiver) { success, error in
            if success {
                completionHandler(.success)
            } else {
                completionHandler(.error(error?.localizedDescription))
            }
        }
    }
    
}
