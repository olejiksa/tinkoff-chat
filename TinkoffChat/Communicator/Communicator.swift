//
//  Communicator.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 03/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

protocol Communicator {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    var delegate: CommunicatorDelegate? { get set }
    var online: Bool { get set }
}
