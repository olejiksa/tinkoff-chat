//
//  ServiceAssembly.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

protocol IServicesAssembly {
    var communicationService: ICommunicatorDelegate { get }
    var themesService: IThemesService { get }
    var frcService: FRCService { get }
    var keyboardService: IKeyboardService { get }
}

class ServicesAssembly: IServicesAssembly {
    
    private let coreAssembly: ICoreAssembly
    
    init(coreAssembly: ICoreAssembly) {
        self.coreAssembly = coreAssembly
    }
    
    lazy var communicationService: ICommunicatorDelegate = CommunicationService(dataManager: coreAssembly.dataManager, communicator: coreAssembly.multipeerCommunicator)
    lazy var themesService: IThemesService = ThemesService(themesManager: coreAssembly.themesManager)
    lazy var frcService: FRCService = FRCService(backdoor: coreAssembly.coreDataBackdoor)
    lazy var keyboardService: IKeyboardService = KeyboardService()
    
}
