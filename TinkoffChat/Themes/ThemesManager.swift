//
//  ThemesManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 22/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import Foundation

final class ThemesManager {
    
    static let shared = ThemesManager()

    private init() {}
    
    func applyTheme(_ themeToApply: UIColor, isSaving: Bool = true) {
        DispatchQueue.global(qos: .utility).async {
            if isSaving {
                UserDefaults.standard.setColor(color: themeToApply, forKey: "themeColor")
            }
            
            DispatchQueue.main.async {
                UINavigationBar.appearance().backgroundColor = themeToApply
                UINavigationBar.appearance().barTintColor = themeToApply
                
                if themeToApply.isLight {
                    UINavigationBar.appearance().tintColor = UIColor.darkText
                    UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkText]
                } else {
                    UINavigationBar.appearance().tintColor = UIColor.lightText
                    UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightText]
                }
                
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
    }
    
}
