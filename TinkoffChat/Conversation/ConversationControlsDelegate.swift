//
//  ConversationControlsDelegate.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 19/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

protocol ConversationControlsDelegate {
    var conversation: Conversation! { get set}
    
    func turnMessagePanelOn()
    func turnMessagePanelOff()
}
