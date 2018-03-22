//
//  ThemesManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 22/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

final class ThemesManager {
    
    static let sharedInstance = ThemesManager()
    
    private init() {}
    
    func applyTheme(_ themeToApply: UIColor) {
        UINavigationBar.appearance().backgroundColor = themeToApply
        UINavigationBar.appearance().barTintColor = themeToApply
        
        if themeToApply.isLight {
            UINavigationBar.appearance().tintColor = UIColor.darkText
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkText]
        } else {
            UINavigationBar.appearance().tintColor = UIColor.lightText
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightText]
        }
        
        UserDefaults.standard.setColor(color: themeToApply, forKey: "themeColor")
        
        // Applies UIAppearance immediately on the screen
        let windows = UIApplication.shared.windows as [UIWindow]
        for window in windows {
            let subviews = window.subviews as [UIView]
            for v in subviews {
                v.removeFromSuperview()
                window.addSubview(v)
            }
        }
    }
    
}
