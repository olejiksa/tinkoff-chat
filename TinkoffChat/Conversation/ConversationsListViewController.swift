//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 09/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData
import UIKit

class ConversationsListViewController: UIViewController {
    
    private var fetchedResultsController: NSFetchedResultsController<Conversation>!
    private var fetchResultManager = FetchedResultsManager()
    private var controlsDelegate: ConversationControlsDelegate?
    
    // MARK: - MultipeerConnectivity
    
    private var communicator: Communicator = MultipeerCommunicator()
    private var communicationManager: CommunicatorDelegate = CommunicationManager()
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communicator.delegate = communicationManager
        tableView.dataSource = self
        tableView.delegate = self
        
        /* Сортировка как и в предыдущих работах:
           высший приоритет - online
           далее приоритетна сортировка по "свежести" последнего сообщения,
           в случае коллизии применяется второй дескриптор: алфавит, по возрастанию */
        let fetchRequest: NSFetchRequest<Conversation> = CoreDataService.shared.getAll(.conversation)
        let onlineSortDescriptor = NSSortDescriptor(key: "isOnline", ascending: false)
        let dateSortDescriptor = NSSortDescriptor(key: "lastMessage.date", ascending: false)
        let nameSortDescriptor = NSSortDescriptor(key: "interlocutor.name", ascending: true)
        fetchRequest.sortDescriptors = [onlineSortDescriptor, dateSortDescriptor, nameSortDescriptor]
        
        fetchResultManager.delegate = tableView
        fetchedResultsController = CoreDataService.shared.setupFRC(fetchRequest, fetchResultManager: fetchResultManager)
        CoreDataService.shared.fetchData(fetchedResultsController)
        
        // Поначалу все диалоги находятся в истории...
        fetchedResultsController?.fetchedObjects?.forEach({ $0.isOnline = false })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showSegue" {
            if let destination = segue.destination as? ConversationViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    controlsDelegate = destination
                    controlsDelegate?.conversation = fetchedResultsController?.object(at: indexPath)

                    destination.communicator = communicator
                    destination.navigationItem.largeTitleDisplayMode = .never
                    destination.navigationItem.title = controlsDelegate?.conversation.interlocutor?.name
                }
            }
        } else if segue.identifier == "themesModalSegue" {
            if let navigationDestination = segue.destination as? UINavigationController {
                if let objcDestination = navigationDestination.viewControllers.first as? ThemesViewController {
                    objcDestination.delegate = self
                } else if let swiftDestination = navigationDestination.viewControllers.first as? SwiftThemesViewController {
                    swiftDestination.closure = { (controller: SwiftThemesViewController, selectedTheme: UIColor?) in
                        guard let theme = selectedTheme else { return }
                        controller.view.backgroundColor = theme
                        ThemesManager.shared.applyTheme(theme)
                    }
                }
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ConversationsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionsCount = fetchedResultsController?.sections?.count else {
            return 0
        }
        
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Conversation"
        var cell: ConversationCell
        
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ConversationCell {
            cell = dequeuedCell
        } else {
            cell = ConversationCell(style: .default, reuseIdentifier: identifier)
        }
        
        if let conversation = fetchedResultsController?.object(at: indexPath) {
            if let interlocutor = conversation.interlocutor {
                cell.name = interlocutor.name
            }
            
            cell.online = conversation.isOnline
            cell.date = conversation.lastMessage?.date ?? nil
            cell.lastMessageText = conversation.lastMessage?.messageText ?? nil
            cell.hasUnreadMessages = conversation.hasUnreadMessages
            
            if conversation.isOnline && conversation == controlsDelegate?.conversation {
                controlsDelegate?.turnMessagePanelOn()
            } else {
                controlsDelegate?.turnMessagePanelOff()
            }
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ConversationsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSegue", sender: indexPath);
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - ThemesViewControllerDelegate

extension ConversationsListViewController: ThemesViewControllerDelegate {
    
    func themesViewController(_ controller: ThemesViewController?, didSelectTheme selectedTheme: UIColor?) {
        guard let theme = selectedTheme else { return }
        controller?.view.backgroundColor = theme
        ThemesManager.shared.applyTheme(theme)
    }
    
}
