//
//  ThemesViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController {
    
    // MARK: - Dependencies
    
    private let model: IThemesModel
    
    // MARK: - Initializers
    
    init(model: IThemesModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationPane()
        
        DispatchQueue.global(qos: .userInteractive).async {
            if let theme = UserDefaults.standard.colorForKey(key: "themeColor") {
                DispatchQueue.main.async {
                    self.view.backgroundColor = theme
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    @IBAction private func didThemeButtonTap(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            model.closure(self, model.theme1)
        case 2:
            model.closure(self, model.theme2)
        case 3:
            model.closure(self, model.theme3)
        default:
            break
        }
    }
    
    private func configureNavigationPane() {
        navigationItem.title = "Темы"
        
        let rightItem = UIBarButtonItem(title: "Закрыть",
                                        style: .plain,
                                        target: self,
                                        action: #selector(close))
        navigationItem.setRightBarButton(rightItem, animated: true)
    }
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
}
