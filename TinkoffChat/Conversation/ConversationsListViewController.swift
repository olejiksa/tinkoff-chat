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
    
    private var communicator: Communicator = MultipeerCommunicator()
    private var communicationManager = CommunicationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communicator.delegate = communicationManager
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name.ConversationsListReloadData, object: nil)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ConversationsListReloadData, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showSegue" {
            if let destination = segue.destination as? ConversationViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    destination.communicator = communicator
                    destination.conversation = communicationManager.conversations[indexPath.section][indexPath.row]
                }
            }
        } else if segue.identifier == "themesModalSegue" {
            if let navigationDestination = segue.destination as? UINavigationController {
                if let objcDestination = navigationDestination.viewControllers.first as? ThemesViewController {
                    objcDestination.delegate = self
                } else if let swiftDestination = navigationDestination.viewControllers.first as? SwiftThemesViewController {
                    swiftDestination.closure = {
                        [unowned self] (controller: SwiftThemesViewController, selectedTheme: UIColor?) in
                        guard let theme = selectedTheme else {
                            return
                        }
                        
                        controller.view.backgroundColor = theme
                        self.logThemeChanging(selectedTheme: theme)

                        ThemesManager.sharedInstance.applyTheme(theme)
                    }
                }
            }
        }
    }
    
    private func logThemeChanging(selectedTheme: UIColor) {
        guard let rgb = selectedTheme.rgb() else { return }
        print(rgb)
    }
    
    @objc private func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension ConversationsListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return communicationManager.conversations.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return communicationManager.conversations[section].count
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
        
        let conversation = communicationManager.conversations[indexPath.section][indexPath.row]
        cell.name = conversation.name
        cell.date = conversation.date
        cell.lastMessageText = conversation.lastMessageText
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

extension ConversationsListViewController: ThemesViewControllerDelegate {
    func themesViewController(_ controller: ThemesViewController?, didSelectTheme selectedTheme: UIColor?) {
        guard let theme = selectedTheme else {
            return
        }
        
        controller?.view.backgroundColor = theme
        logThemeChanging(selectedTheme: theme)
        
        ThemesManager.sharedInstance.applyTheme(theme)
    }
}
