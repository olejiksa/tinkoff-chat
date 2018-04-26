//
//  ThemesService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 24/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IThemesService: class {
    func load()
    func save(_ theme: UIColor)
}

class ThemesService: IThemesService {
    
    private let themesManager: IThemesManager
    
    init(themesManager: IThemesManager) {
        self.themesManager = themesManager
    }
    
    func load() {
        themesManager.loadAndApply()
    }
    
    func save(_ theme: UIColor) {
        themesManager.apply(theme, save: true)
    }
    
}
