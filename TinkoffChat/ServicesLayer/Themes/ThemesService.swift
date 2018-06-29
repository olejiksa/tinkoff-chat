//
//  ThemesService.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 24/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IThemesService: class {
    var current: UIColor? { get set }
    
    func load(completion: (() -> ())?)
    func save(_ theme: UIColor, completion: (() -> ())?)
    func invert(_ theme: UIColor, completion: ((Bool) -> ())?)
}

class ThemesService: IThemesService {
    
    private let themesManager: IThemesManager
    
    var current: UIColor? {
        didSet {
            if current == nil {
                // applying default color
                themesManager.apply(#colorLiteral(red: 0.9567915797, green: 0.8335112333, blue: 0, alpha: 1), save: false, completion: nil)
            }
        }
    }
    
    init(themesManager: IThemesManager) {
        self.themesManager = themesManager
    }
    
    func load(completion: (() -> ())?) {
        themesManager.loadAndApply() { result in
            self.current = result
            completion?()
        }
    }
    
    func save(_ theme: UIColor, completion: (() -> ())?) {
        themesManager.apply(theme, save: true) {
            self.current = theme
            completion?()
        }
    }
    
    func invert(_ theme: UIColor, completion: ((Bool) -> ())?) {
        let inverted = theme.invertedColor
        
        themesManager.apply(theme.invertedColor, save: false) {
            self.current = inverted
            completion?(theme.isLight != inverted.isLight)
        }
    }
    
}
