//
//  ConversationViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 10/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    // MARK: - Dependencies
    
    private var model: ConversationModel
    
    // MARK: - Initializers
    
    init(model: ConversationModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        configureTableView()
        model.dataProvider = MessagesDataProvider(delegate: tableView, fetchRequest: model.frcService.messagesInConversation(with: model.conversation.conversationId!)!, context: model.frcService.saveContext)
        
        /* Содержимое messageTextField просматривается
         * для изменения состояния sendButton */
        messageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        if let count = model.conversation.messages?.count, count > 0 {
            // Скроллинг до последнего сообщения после загрузки данных
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        turnKeyboard(on: true)
        
        // Обработка тапов в любой точке view вне самой клавиатуры
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        if model.conversation.isOnline {
            turnMessagePanelOn()
        } else {
            turnMessagePanelOff()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        turnKeyboard(on: false)
        model.makeRead()
        
        view.gestureRecognizers?.removeAll()
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapSendButton() {
        guard let text = messageTextField.text,
            let receiver = model.conversation.interlocutor?.userId, !text.isEmpty else { return }
        
        model.communicationService.communicator.sendMessage(text: text, to: receiver) { [weak self] success, error in
            if success {                
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
    
    // MARK: - Private methods
    
    private func configureTableView() {
        tableView.register(UINib(nibName: "IncomingMessageCell", bundle: nil),
                           forCellReuseIdentifier: "MessageIn")
        tableView.register(UINib(nibName: "OutcomingMessageCell", bundle: nil),
                           forCellReuseIdentifier: "MessageOut")
        
        tableView.dataSource = self
        tableView.delegate = self as? UITableViewDelegate
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Keyboard
    
    private func turnKeyboard(on: Bool) {
        if on {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name:
                .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:
                .UIKeyboardWillHide, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(inputModeDidChange), name:
                .UIKeyboardWillChangeFrame, object: nil)
            
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        } else {
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
            NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
            
            view.gestureRecognizers?.removeAll()
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ConversationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionsCount = model.dataProvider?.fetchedResultsController.sections?.count else {
            return 0
        }
        
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = model.dataProvider?.fetchedResultsController.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MessageCell?
        
        if let message = model.dataProvider?.fetchedResultsController.object(at: indexPath) {
            let identifier = message.isIncoming ? "MessageIn" : "MessageOut"
            
            if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MessageCell {
                cell = dequeuedCell
            } else {
                cell = MessageCell(style: .default, reuseIdentifier: identifier)
            }
            
            cell?.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell?.messageText = message.messageText
            cell?.isIncoming = message.isIncoming
            cell?.date = message.date
        }
        
        return cell ?? UITableViewCell()
    }
    
}

// MARK: - IConversationControlsDelegate

extension ConversationViewController {
    
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
