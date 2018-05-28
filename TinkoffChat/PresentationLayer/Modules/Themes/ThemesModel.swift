//
//  ThemesModel.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 23/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

typealias Colorization = ((ThemesViewController, UIColor?) -> ())

protocol IThemesModel: class {
    var theme1: UIColor { get }
    var theme2: UIColor { get }
    var theme3: UIColor { get }
    
    typealias Colorization = ((ThemesViewController, UIColor?) -> ())
    var closure: Colorization { get }
    
    func invert(_ theme: UIColor)
}

class ThemesModel: IThemesModel {
    
    private let themesService: IThemesService
    
    var theme1, theme2, theme3: UIColor
    var closure: Colorization

    init(theme1: UIColor, theme2: UIColor, theme3: UIColor, themesService: IThemesService, closure: @escaping Colorization) {
        self.theme1 = theme1
        self.theme2 = theme2
        self.theme3 = theme3
        
        self.themesService = themesService
        self.closure = closure
    }
    
    func invert(_ theme: UIColor) {
        themesService.invert(theme, completion: nil)
    }
    
}
