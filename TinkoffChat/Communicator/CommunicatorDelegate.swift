//
//  CommunicatorDelegate.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 03/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

protocol CommunicatorDelegate: class {
    // discovering
    func didFoundUser(userID: String, userName: String?)
    func didLostUser(userID: String)
    
    // errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    // messages
    func didReceiveMessage(text: String, fromUser: String, toUser: String)
}
