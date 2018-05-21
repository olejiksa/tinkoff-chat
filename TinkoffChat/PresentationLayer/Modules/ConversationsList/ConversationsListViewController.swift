//
//  ConversationsListViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 09/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    private var emitter: Emitter!
    
    // MARK: - Dependencies
    
    private var model: IConversationsListModel
    private let presentationAssembly: IPresentationAssembly
    
    // MARK: - Initializers
    
    init(model: IConversationsListModel, presentationAssembly: IPresentationAssembly) {
        self.model = model
        self.presentationAssembly = presentationAssembly
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.restoreThemeSettings()
        configureTableView()
        configureData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationPane()
    }
    
    // MARK: - Private methods
    
    private func configureNavigationPane() {
        navigationItem.title = "Tinkoff Chat"

        let leftItem = UIBarButtonItem(title: "Темы",
                                       style: .plain,
                                       target: self,
                                       action: #selector(themes))
        navigationItem.setLeftBarButton(leftItem, animated: true)
        
        let rightItem = UIBarButtonItem(title: "Профиль",
                                        style: .plain,
                                        target: self,
                                        action: #selector(profile))
        navigationItem.setRightBarButton(rightItem, animated: true)
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "\(ConversationCell.self)", bundle: nil),
                           forCellReuseIdentifier: "\(ConversationCell.self)")
    }
    
    private func configureData() {
        let pair = model.linkedServices()
        model.dataProvider = ConversationsDataProvider(delegate: tableView, fetchRequest: pair.1.allConversations(), context: pair.1.saveContext)
    }
    
    @objc private func themes() {
        let controller = presentationAssembly.themesViewController() { [weak self] (controller: ThemesViewController, selectedTheme: UIColor?) in
            guard let theme = selectedTheme else { return }
            controller.view.backgroundColor = theme
            self?.model.saveSettings(for: theme)
        }
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [controller]
        
        emitter = Emitter(view: navigationController.view)
        
        present(navigationController, animated: true)
    }
    
    @objc private func profile() {
        let controller = presentationAssembly.profileViewController()
        
        let navigationController = UINavigationController()
        navigationController.viewControllers = [controller]
        
        emitter = Emitter(view: navigationController.view)
        
        present(navigationController, animated: true)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource

extension ConversationsListViewController: UITableViewDataSource {
    
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
        let identifier = "\(ConversationCell.self)"
        var cell: ConversationCell
        
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ConversationCell {
            cell = dequeuedCell
        } else {
            cell = ConversationCell(style: .default, reuseIdentifier: identifier)
        }
        
        if let conversation = model.dataProvider?.fetchedResultsController.object(at: indexPath) {
            if let interlocutor = conversation.interlocutor {
                cell.name = interlocutor.name
            }
            
            cell.online = conversation.isOnline
            cell.date = conversation.lastMessage?.date ?? nil
            cell.lastMessageText = conversation.lastMessage?.messageText ?? nil
            cell.hasUnreadMessages = conversation.hasUnreadMessages
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
        guard let conversation = model.dataProvider?.fetchedResultsController.object(at: indexPath)
              else { return }
        let controller = presentationAssembly.conversationViewController(model: model, conversation: conversation)

        controller.navigationItem.title = conversation.interlocutor?.name
        navigationController?.pushViewController(controller, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
