//
//  AppDelegate.swift
//  marvel111
//
//  Created by Valery Shestakov on 20.10.2022.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        let listViewController = ListViewController()
        let navigationController = UINavigationController(rootViewController: listViewController)

        window.rootViewController = navigationController

        window.makeKeyAndVisible()

        self.window = window

        return true
    }
}
