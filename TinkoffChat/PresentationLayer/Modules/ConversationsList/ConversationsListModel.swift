//
//  ConversationsListModel.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IConversationListModel: class {
    var communicationService: ICommunicatorDelegate { get }
    var frcService: IFRCService { get }
    var dataProvider: ConversationsDataProvider? { get set }
    
    func restoreThemeSettings()
    func saveSettings(for theme: UIColor)
}

class ConversationsListModel: IConversationListModel {
    
    private let themesService: IThemesService
    
    var communicationService: ICommunicatorDelegate
    var frcService: IFRCService
    var dataProvider: ConversationsDataProvider?

    init(communicationService: ICommunicatorDelegate,
         themesService: IThemesService,
         frcService: IFRCService) {
        self.themesService = themesService
        self.communicationService = communicationService
        self.frcService = frcService
    }
        
    func restoreThemeSettings() {
        themesService.load()
    }
    
    func saveSettings(for theme: UIColor) {
        themesService.save(theme)
    }
    
}
