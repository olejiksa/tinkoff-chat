//
//  SwiftThemesViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class SwiftThemesViewController: UIViewController {
    
    private let model = Themes(theme1: #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), theme2: #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), theme3: #colorLiteral(red: 1, green: 0.9572783113, blue: 0.3921568627, alpha: 1))
    
    var closure: ((SwiftThemesViewController, UIColor?) -> ())?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .userInteractive).async {
            let savedTheme = UserDefaults.standard.colorForKey(key: "themeColor")
            
            if let theme = savedTheme {
                DispatchQueue.main.async {
                    self.view.backgroundColor = theme
                }
            }
        }
    }
    
    @IBAction private func didCloseBarButtonItemTap() {
        dismiss(animated: true)
    }
    
    @IBAction private func didThemeButtonTap(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            closure?(self, model?.theme1)
        case 2:
            closure?(self, model?.theme2)
        case 3:
            closure?(self, model?.theme3)
        default:
            break
        }
    }
    
}