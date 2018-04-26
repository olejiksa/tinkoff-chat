//
//  CoreAssembly.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

protocol ICoreAssembly {
    var multipeerCommunicator: ICommunicator { get }
    var themesManager: IThemesManager { get }
    var dataManager: IDataManager { get }
    var coreDataBackdoor: ICoreDataStackBackdoor { get }
}

class CoreAssembly: ICoreAssembly {
    private let coreDataManager = CoreDataManager()
    
    lazy var multipeerCommunicator: ICommunicator = MultipeerCommunicator()
    lazy var themesManager: IThemesManager = ThemesManager()
    lazy var dataManager: IDataManager = coreDataManager
    lazy var coreDataBackdoor: ICoreDataStackBackdoor = coreDataManager
}
