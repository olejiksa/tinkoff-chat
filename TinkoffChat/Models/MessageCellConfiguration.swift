//
//  MessageCellConfiguration.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 11/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

protocol MessageCellConfiguration {
    var messageText: String? { get set }
    var isIncoming: Bool { get set }
}
