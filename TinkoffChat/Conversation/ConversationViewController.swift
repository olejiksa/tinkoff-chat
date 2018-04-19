//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 10/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData
import UIKit

class ConversationViewController: UIViewController {
    
    var communicator: Communicator!
    var conversation: Conversation!
    
    private var fetchedResultController: NSFetchedResultsController<Message>!
    private var fetchResultManager = FetchedResultsManager()

    // MARK: - Outlets
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }
    
    @IBOutlet private weak var messageTextField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let fetchRequest: NSFetchRequest<Message> = CoreDataService.shared.fetchRequest(.messagesInConversation, substitutionDictionary: ["conversationId": conversation.conversationId!])!
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchResultManager.delegate = tableView
        fetchedResultController = CoreDataService.shared.setupFRC(fetchRequest, fetchResultManager: fetchResultManager)
        CoreDataService.shared.fetchData(fetchedResultController!)
        
        /* Содержимое messageTextField просматривается
         * для изменения состояния sendButton */
        messageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Обработка тапов в любой точке view вне самой клавиатуры
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        if let count = conversation.messages?.count, count > 0 {
            // Скроллинг до последнего сообщения после загрузки данных
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear),
                                               name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(inputModeDidChange),
                                               name: .UIKeyboardWillChangeFrame, object: nil)
        
        CoreDataService.shared.coreDataStack.saveContext.perform {
            if self.conversation.isOnline {
                self.turnMessagePanelOn()
            } else {
                self.turnMessagePanelOff()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
        
        CoreDataService.shared.coreDataStack.saveContext.perform {
            self.conversation.hasUnreadMessages = false
            CoreDataService.shared.save()
        }
        
        view.gestureRecognizers?.removeAll()
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapSendButton() {
        let textCanBe = messageTextField.text
        var receiverCanBe: String? = ""
        
        CoreDataService.shared.coreDataStack.saveContext.perform {
            receiverCanBe = self.conversation.interlocutor?.userId
        }
        
        guard let text = textCanBe, let receiver = receiverCanBe, !text.isEmpty else { return }
        
        communicator.sendMessage(string: text, to: receiver) { [weak self] success, error in
            if success {
                CoreDataService.shared.coreDataStack.saveContext.perform {
                    let message: Message = CoreDataService.shared.add(.message)
                    message.messageId = Message.generateMessageId()
                    message.date = Date()
                    message.isIncoming = false
                    message.messageText = text
                    message.conversation = self?.conversation
                    message.lastMessageInConversation = self?.conversation
                    
                    CoreDataService.shared.save()
                }
                
                self?.messageTextField.text = nil
                self?.sendButton.isEnabled = false
            } else {
                let alert = UIAlertController(title: "Ошибка",
                                              message: error?.localizedDescription,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == messageTextField {
            if let text = messageTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                sendButton.isEnabled = true
            } else {
                sendButton.isEnabled = false
            }
        }
    }
    
    // MARK: - Keyboard
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
        view.frame.origin.y = 0
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y >= 0 {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y += keyboardSize.height
        }
    }
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            view.frame.origin.y -= keyboardSize.height
        }
    }
    
    @objc private func inputModeDidChange(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
}

// MARK: - UITableViewDataSource

extension ConversationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionsCount = fetchedResultController?.sections?.count else {
            return 0
        }
        
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultController.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MessageCell
        
        let message = fetchedResultController.object(at: indexPath)
        let identifier = message.isIncoming ? "MessageIn" : "MessageOut"
        
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MessageCell {
            cell = dequeuedCell
        } else {
            cell = MessageCell(style: .default, reuseIdentifier: identifier)
        }
        
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.messageText = message.messageText
        cell.isIncoming = message.isIncoming
        cell.date = message.date
        
        return cell
    }
    
}

// MARK: - ConversationControlsDelegate

extension ConversationViewController: ConversationControlsDelegate {
    
    func turnMessagePanelOn() {
        DispatchQueue.main.async {
            self.textFieldDidChange(self.messageTextField)
            self.messageTextField.isEnabled = true
        }
    }
    
    func turnMessagePanelOff() {
        DispatchQueue.main.async {
            self.sendButton.isEnabled = false
            self.messageTextField.isEnabled = false
        }
    }
    
}
