//
//  ConversationModel.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 24/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

protocol IConversationModel: class {
    var conversation: Conversation { get set }
    var communicationService: ICommunicatorDelegate { get set }
}

class ConversationModel: IConversationModel {
    
    let frcService: IFRCService
    
    var conversation: Conversation
    var communicationService: ICommunicatorDelegate
    var dataProvider: MessagesDataProvider?
    
    init(communicationService: ICommunicatorDelegate,
         frcService: IFRCService,
         conversation: Conversation) {
        self.communicationService = communicationService
        self.conversation = conversation
        self.frcService = frcService
    }
    
    func makeRead() {
        guard let id = conversation.conversationId else { return }
        communicationService.didConversationRead(id: id)
    }
    
}
