//
//  PresentationAssembly.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IPresentationAssembly {
    func conversationViewController(model: ConversationModel) -> ConversationViewController
    func conversationModel(model: IConversationsListModel, conversation: Conversation) -> ConversationModel
    func conversationsListViewController() -> ConversationsListViewController
    func profileViewController() -> ProfileViewController
    func themesViewController(_ closure: @escaping Colorization) -> ThemesViewController
}

class PresentationAssembly: IPresentationAssembly {
    
    private let servicesAssembly: IServicesAssembly
    
    init(serviceAssembly: IServicesAssembly) {
        self.servicesAssembly = serviceAssembly
    }
    
    // MARK: - ConversationViewController
    
    func conversationViewController(model: ConversationModel) -> ConversationViewController {
        return ConversationViewController(model: model)
    }
    
    func conversationModel(model: IConversationsListModel, conversation: Conversation) -> ConversationModel {
        return ConversationModel(communicationService: model.communicationService, frcService: model.frcService, keyboardService: servicesAssembly.keyboardService, conversation: conversation)
    }
    
    // MARK: - ConversationsListViewController
    
    func conversationsListViewController() -> ConversationsListViewController {
        return ConversationsListViewController(model: conversationsListModel(),
                                               presentationAssembly: self)
    }
    
    private func conversationsListModel() -> IConversationsListModel {
        return ConversationsListModel(communicationService: servicesAssembly.communicationService,
                                      themesService: servicesAssembly.themesService,
                                      frcService: servicesAssembly.frcService)
    }
    
    // MARK: - ProfileViewController
    
    func profileViewController() -> ProfileViewController {
        return ProfileViewController(model: profileModel())
    }
    
    private func profileModel() -> IAppUserModel {
        return ProfileModel(dataService: CoreDataManager(), keyboardService: servicesAssembly.keyboardService, permissionsService: servicesAssembly.permissionsService)
    }
    
    // MARK: - ThemesViewController
    
    func themesViewController(_ closure: @escaping Colorization) -> ThemesViewController {
        return ThemesViewController(model: themesModel(closure))
    }
    
    private func themesModel(_ closure: @escaping Colorization) -> IThemesModel {
        return ThemesModel(theme1: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), theme2: #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1), theme3: #colorLiteral(red: 1, green: 0.9572783113, blue: 0.3921568627, alpha: 1), closure: closure)
    }
    
}
