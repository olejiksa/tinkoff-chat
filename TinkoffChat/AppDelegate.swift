//
//  AppDelegate.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/02/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let rootAssembly = RootAssembly()
    private var emitter: Emitter!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let controller = rootAssembly.presentationAssembly.conversationsListViewController()
        let navigationController = UINavigationController(rootViewController: controller)

        emitter = Emitter(view: navigationController.view)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    
}
