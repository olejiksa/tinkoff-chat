//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 10/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    private var sendLock = false
    var communicator: Communicator!
    var conversation: Conversation!
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }
    
    @IBOutlet private weak var messageTextField: UITextField!
    @IBOutlet private weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = conversation.name
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        
        messageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        if conversation.messages.count > 0 {
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name.ConversationReloadData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(turnSendOff), name: Notification.Name.ConversationTurnSendOff, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ConversationReloadData, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ConversationTurnSendOff, object: nil)
        
        conversation.hasUnreadMessages = false
        
        view.gestureRecognizers?.removeAll()
    }
    
    @IBAction func didSendButtonTap() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        
        communicator.sendMessage(string: text, to: conversation.id) { [weak self] success, error in
            if success {
                self?.messageTextField.text = nil
                
                self?.conversation.messages.insert(Message(messageText: text, isIncoming: false), at: 0)
                self?.conversation.lastMessageText = text
                self?.conversation.date = Date()
                self?.tableView.reloadData()
                
                NotificationCenter.default.post(name: Notification.Name.ConversationsListSortData, object: nil)
            } else {
                let alert = UIAlertController(title: "Ошибка", message: "Не удалось отправить сообщение.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
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
    
    @objc private func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc private func turnSendOff() {
        DispatchQueue.main.async {
            self.sendLock = true
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == messageTextField {
            if let text = messageTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty, !sendLock {
                sendButton.isEnabled = true
            } else {
                sendButton.isEnabled = false
            }
        }
    }
}

extension ConversationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = conversation.messages[indexPath.row]
        let identifier = message.isIncoming ? "MessageIn" : "MessageOut"
        var cell: MessageCell
        
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MessageCell {
            cell = dequeuedCell
        } else {
            cell = MessageCell(style: .default, reuseIdentifier: identifier)
        }
        
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.messageText = message.messageText
        cell.isIncoming = message.isIncoming
        
        return cell
    }
}
