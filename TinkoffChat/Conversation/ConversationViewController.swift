//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 10/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAllConversations()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = self
        tableView.delegate = self
    } 
    
    private func addAllConversations() {
        messages += [Message(messageText: "1", isIncoming: true),
                     Message(messageText: "123456789012345678901234567890", isIncoming: true),
                     Message(messageText: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec.", isIncoming: true)]
        for i in 0..<messages.count {
            messages.append(messages[i])
            messages[i].isIncoming = false
        }
    }
    
}

extension ConversationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let identifier = message.isIncoming ? "MessageIn" : "MessageOut"
        var cell: MessageCell
        
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MessageCell {
            cell = dequeuedCell
        } else {
            cell = MessageCell(style: .default, reuseIdentifier: identifier)
        }
        
        cell.messageText = message.messageText
        cell.isIncoming = message.isIncoming
        
        return cell
    }
    
}
