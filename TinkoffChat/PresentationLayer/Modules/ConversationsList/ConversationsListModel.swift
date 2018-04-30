//
//  ConversationsListModel.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IConversationsListModel: class {
    var communicationService: ICommunicatorDelegate { get }
    var frcService: FRCService { get }
    var dataProvider: ConversationsDataProvider? { get set }
    
    func restoreThemeSettings()
    func saveSettings(for theme: UIColor)
}

class ConversationsListModel: IConversationsListModel {
    
    private let themesService: IThemesService
    
    var communicationService: ICommunicatorDelegate
    var frcService: FRCService
    var dataProvider: ConversationsDataProvider?

    init(communicationService: ICommunicatorDelegate,
         themesService: IThemesService,
         frcService: FRCService) {
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
