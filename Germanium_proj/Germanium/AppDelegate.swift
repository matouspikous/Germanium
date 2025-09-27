//
//  AppDelegate.swift
//  Germanium
//
//  Created by Matouš Pikous on 25/09/2025.
//  Copyright © 2025 Matouš Pikous. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let tabBarController = UITabBarController()

        let writingVC = UINavigationController(rootViewController: WritingViewController())
        writingVC.tabBarItem = UITabBarItem(title: "Writing", image: nil, selectedImage: nil)

        let orderingVC = UINavigationController(rootViewController: OrderingViewController())
        orderingVC.tabBarItem = UITabBarItem(title: "Ordering", image: nil, selectedImage: nil)
        
        // Ads Tab
        //let adsVC = UINavigationController(rootViewController: AdsViewController())
        //adsVC.tabBarItem = UITabBarItem(title: "Ads", image: nil, selectedImage: nil)


        tabBarController.viewControllers = [writingVC, orderingVC]

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        return true
    }
}
