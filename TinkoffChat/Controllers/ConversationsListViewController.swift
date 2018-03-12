//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 09/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var conversations = [[Conversation]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAllConversations()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showSegue" {
            if let destination = segue.destination as? ConversationViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let name = conversations[indexPath.section][indexPath.row].name
                    destination.navigationItem.title = name ?? "Name"
                }
            }
        }
    }
    
    private func addAllConversations() {
        // online
        conversations += [[Conversation(name: "Kirill",
                                        message: "Hi, how're u?",
                                        date: Date.init(timeIntervalSinceNow: 0),
                                        online: true,
                                        hasUnreadMessages: true),
                           Conversation(name: "Serg",
                                        message: "Hey!",
                                        date: Date.init(timeIntervalSinceNow: -2*60*60*24),
                                        online: true,
                                        hasUnreadMessages: false),
                           Conversation(name: "Kate",
                                        message: "Запилила лекцию... на 80%",
                                        date: Date.init(timeIntervalSinceNow: -3*60*60*24),
                                        online: true,
                                        hasUnreadMessages: false),
                           Conversation(name: "Alex",
                                        message: "Готово на 30%",
                                        date: Date(from: "10 Mar 2018 15:28"),
                                        online: true,
                                        hasUnreadMessages: true),
                           Conversation(name: "Philip",
                                        message: "Hahaha",
                                        date: Date(from: "8 Mar 2018 19:00"),
                                        online: true,
                                        hasUnreadMessages: true),
                           Conversation(name: "Santa",
                                        message: "Happy New Year!",
                                        date: Date(from: "31 Dec 2018 23:59"),
                                        online: true,
                                        hasUnreadMessages: false),
                           Conversation(name: "I have the longest weird name in this world",
                                        message: "Happy New Year!",
                                        date: Date(from: "13 Jun 2018 23:59"),
                                        online: true,
                                        hasUnreadMessages: false),
                           Conversation(name: nil,
                                        message: "NoName&NoClan and NoName&NoClan a bit more",
                                        date: Date(from: "11 Jun 2018 23:59"),
                                        online: true,
                                        hasUnreadMessages: true),
                           Conversation(name: "Big Brother",
                                        message: nil,
                                        date: nil,
                                        online: true,
                                        hasUnreadMessages: false)]]
        //history
        conversations.append([Conversation]())
        for i in 0..<conversations[0].count-1 {
            conversations[1].append(conversations[0][i])
            conversations[1][i].online = false
        }
        conversations[1].append(Conversation(name: "Selfish nut",
                                             message: "Talk me!!!111",
                                             date: Date.init(timeIntervalSinceNow: -60*60*24),
                                             online: false,
                                             hasUnreadMessages: true))
    }
    
}

extension ConversationsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Online" : "History"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Conversation"
        var cell: ConversationCell
        
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ConversationCell {
            cell = dequeuedCell
        } else {
            cell = ConversationCell(style: .default, reuseIdentifier: identifier)
        }
        
        let conversation = conversations[indexPath.section][indexPath.row]
        cell.name = conversation.name
        cell.date = conversation.date
        cell.message = conversation.message
        cell.online = conversation.online
        cell.hasUnreadMessages = conversation.hasUnreadMessages
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSegue", sender: indexPath);
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
