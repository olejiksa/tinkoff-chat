//
//  Message.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 11/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class Message: MessageCellConfiguration {
    var messageText: String?
    var isIncoming: Bool
    
    init(messageText: String?, isIncoming: Bool) {
        self.messageText = messageText
        self.isIncoming = isIncoming
    }
}
