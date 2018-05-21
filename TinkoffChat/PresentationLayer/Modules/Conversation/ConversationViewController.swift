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
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
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
    
    private var titleLabel: UILabel!
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureDataProvider()
        configureControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        model.setKeyboardDelegate(view)
        model.turnKeyboard(on: true)
        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        turnMessagePanel(on: model.conversation.isOnline)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        model.turnKeyboard(on: false)
        model.setKeyboardDelegate(nil)
        model.makeRead()
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapSendButton() {
        guard let text = messageTextField.text,
              let receiver = model.conversation.conversationId, !text.isEmpty else { return }
        
        model.sendMessage(text: text, receiver: receiver) { [weak self] result in
            switch result {
            case .success:
                self?.messageTextField.text = nil
                self?.turnButtonWithAnimation(sendButton, on: false)
            case .error(let text):
                let alert = UIAlertController(title: "Ошибка",
                                              message: text,
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == messageTextField {
            if let text = messageTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                turnButtonWithAnimation(sendButton, on: true)
            } else {
                turnButtonWithAnimation(sendButton, on: false)
            }
        }
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
    
    private func configureNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
    }
    
    private func configureDataProvider() {
        guard let id = model.conversation.conversationId else { return }
        
        model.dataProvider = MessagesDataProvider(delegate: tableView, fetchRequest: model.frcService.messagesInConversation(with: id), context: model.frcService.saveContext)
    }
    
    private func configureControls() {
        /* Содержимое messageTextField просматривается
         * для изменения состояния sendButton */
        messageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        if let count = model.conversation.messages?.count, count > 0 {
            // Скроллинг до последнего сообщения после загрузки данных
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        
        model.setOnlineObserver(self)
        
        titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = model.conversation.interlocutor?.name
        
        navigationItem.titleView = titleLabel
    }
    
    private func turnButtonWithAnimation(_ button: UIButton, on: Bool) {
        guard button.isEnabled != on else {
            // Состояние кнопки не изменилось,
            // дабы не анимировать один и тот же цвет - ничего не делаем
            return
        }
        
        let color = on ? #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 1) : #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        
        UIView.animate(withDuration: 0.5, animations: {
            button.isEnabled = on
            button.setTitleColor(color, for: .normal)
            button.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                button.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    private func turnLabelWithAnimation(_ label: UILabel, on: Bool) {
        let color = on ? #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let scaling: CGFloat = on ? 1.1 : 1
        
        guard label.textColor != color else {
            // Состояние надписи не изменилось,
            // дабы не анимировать один и тот же цвет - ничего не делаем
            return
        }
        
        UIView.animate(withDuration: 1, animations: {
            label.textColor = color
            label.transform = CGAffineTransform(scaleX: scaling, y: scaling)
        })
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

// MARK: - IOnlineObserver

extension ConversationViewController: IOnlineObserver {
    
    func turnMessagePanel(on: Bool) {
        /* Меняет доступность ввода сообщения и отправки в зависимости
         * от онлайна другого юзера */
        if on {
            messageTextField.isEnabled = true
            textFieldDidChange(messageTextField)
            turnLabelWithAnimation(titleLabel, on: true)
        } else {
            messageTextField.isEnabled = false
            turnLabelWithAnimation(titleLabel, on: false)
            turnButtonWithAnimation(sendButton, on: false)
        }
    }
    
}
