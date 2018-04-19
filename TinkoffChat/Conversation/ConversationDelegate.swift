//
//  ConversationDelegate.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 16/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

protocol ConversationDelegate {
    func beginUpdates()
    func endUpdates()
    
    func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)
    func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)
    func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation)
    
    func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation)
    func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation)
    func reloadSections(_ sections: IndexSet, with animation: UITableViewRowAnimation)
}
