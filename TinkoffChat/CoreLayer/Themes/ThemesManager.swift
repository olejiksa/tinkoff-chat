//
//  ThemesManager.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 22/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol IThemesManager {
    func apply(_ theme: UIColor, save: Bool, completion: (() -> ())?)
    func loadAndApply(completion: @escaping (UIColor?) -> ())
}

class ThemesManager: IThemesManager {
    
    func apply(_ theme: UIColor, save: Bool, completion: (() -> ())?) {
        DispatchQueue.global(qos: .utility).async {
            if save {
                UserDefaults.standard.setColor(color: theme, forKey: "themeColor")
            }
            
            completion?()
            
            DispatchQueue.main.async {
                UINavigationBar.appearance().backgroundColor = theme
                UINavigationBar.appearance().barTintColor = theme
                
                if theme.isLight {
                    UINavigationBar.appearance().tintColor = .darkText
                    UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkText]
                } else {
                    UINavigationBar.appearance().tintColor = .lightText
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
    
    func loadAndApply(completion: @escaping (UIColor?) -> ()) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let theme = UserDefaults.standard.colorForKey(key: "themeColor") {
                DispatchQueue.main.async {
                    self.apply(theme, save: false) {
                        completion(theme)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
}
