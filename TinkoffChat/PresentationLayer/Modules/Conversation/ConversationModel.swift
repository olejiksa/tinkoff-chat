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
    var communicationService: ICommunicatorDelegate { get }
    var frcService: IFRCService { get }
    var dataProvider: MessagesDataProvider? { get set }
    
    func makeRead()
}

class ConversationModel: IConversationModel {
    
    private var keyboardService: IKeyboardService
    var conversation: Conversation
    var communicationService: ICommunicatorDelegate
    var frcService: IFRCService
    var dataProvider: MessagesDataProvider?
    
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
    
}
