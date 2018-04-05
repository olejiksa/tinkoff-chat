//
//  ConversationCellConfiguration.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 09/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

protocol ConversationCellConfiguration {
    var name: String? { get set }
    var lastMessageText: String? { get set }
    var date: Date? { get set }
    var online: Bool { get set }
    var hasUnreadMessages: Bool { get set }
}
