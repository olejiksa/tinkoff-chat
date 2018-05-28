//
//  ThemesViewController.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/03/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

protocol ThemesSelector: class {
    func didThemeButtonTap(_ sender: UIButton)
}

class ThemesViewController: UIViewController, ThemesSelector {
    
    // MARK: - Dependencies
    
    private let model: IThemesModel
    var mock: ThemesSelector?
    
    // MARK: - Initializers
    
    init(model: IThemesModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Outlet
    
    @IBOutlet var buttonsWithTag: [UIButton]!
    
    // MARK: - UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        configureNavigationPane()
        
        DispatchQueue.global(qos: .userInteractive).async {
            if let theme = UserDefaults.standard.colorForKey(key: "themeColor") {
                DispatchQueue.main.async {
                    self.view.backgroundColor = theme
                }
            }
        }
    }
    
    // MARK: - Action
    
    @IBAction func didThemeButtonTap(_ sender: UIButton) {
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
        
        mock?.didThemeButtonTap(sender)
    }
    
    @IBAction func didInvertButtonTap() {
        guard let color = view.backgroundColor else { return }
        
        model.invert(color)
        model.closure(self, color.invertedColor)
    }
    
    // MARK: - Private methods
    
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
    
    // MARK: - Deinitializers
    
    deinit {
        buttonsWithTag = nil
    }
}
