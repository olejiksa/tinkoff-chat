//
//  ConversationsListModel.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

typealias LinkedServices = (ICommunicatorDelegate, IFRCService)

protocol IConversationsListModel: class {
    var dataProvider: ConversationsDataProvider? { get set }
    
    func restoreThemeSettings()
    func saveSettings(for theme: UIColor)
    
    func linkedServices() -> LinkedServices
}

class ConversationsListModel: IConversationsListModel {
    
    private let themesService: IThemesService
    private var communicationService: ICommunicatorDelegate
    private var frcService: IFRCService
    
    var dataProvider: ConversationsDataProvider?

    init(communicationService: ICommunicatorDelegate,
         themesService: IThemesService,
         frcService: IFRCService) {
        self.themesService = themesService
        self.communicationService = communicationService
        self.frcService = frcService
    }
    
    // MARK: - Themes
    
    func restoreThemeSettings() {
        themesService.load(completion: nil)
    }
    
    func saveSettings(for theme: UIColor) {
        themesService.save(theme, completion: nil)
    }
    
    // MARK: - ConversationModel
    
    // Needed to pass data into its controller...
    func linkedServices() -> LinkedServices {
        return (communicationService, frcService)
    }
    
}
