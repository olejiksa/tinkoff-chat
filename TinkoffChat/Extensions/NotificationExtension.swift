//
//  NotificationExtension.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 05/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let ConversationsListReloadData = Notification.Name("ConversationsListReloadData")
    static let ConversationsListSortData = Notification.Name("ConversationsListSortData")
    static let ConversationReloadData = Notification.Name("ConversationReloadData")
    static let ConversationTurnSendOff = Notification.Name("ConversationTurnSendOff")
}
