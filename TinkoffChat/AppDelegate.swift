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
    private var fromState: UIBaseApplicationState = UIExtraApplicationState.notRunning

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        changeState(to: application.applicationState, by: #function)

        window = UIWindow(frame: UIScreen.main.bounds)
        if let _window = window {
            _window.rootViewController = ViewController()
            _window.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        changeState(to: UIApplicationState.inactive, by: #function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        changeState(to: application.applicationState, by: #function)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        changeState(to: UIApplicationState.inactive, by: #function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        changeState(to: application.applicationState, by: #function)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        changeState(to: UIExtraApplicationState.suspended, by: #function)
    }
    
    private func changeState(to state: UIBaseApplicationState, by functionName: String) {
        print("Application moved from \(fromState.name) to \(state.name): \(functionName)")
        fromState = state
    }
    
    private enum UIExtraApplicationState: Int, UIBaseApplicationState {
        case notRunning, suspended
        var name: String {
            switch self {
            case .notRunning:
                return "Not running"
            case .suspended:
                return "Suspended"
            }
        }
    }
    
}

fileprivate protocol UIBaseApplicationState {
    var name: String { get }
}

extension UIApplicationState: UIBaseApplicationState {
    var name: String {
        switch self {
        case .active:
            return "Active"
        case .background:
            return "Background"
        case .inactive:
            return "Inactive"
        }
    }
}
