//
//  AppDelegate.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/24/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.tintColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
        let barColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
        let pressedTintColor = UIColor.white
        UITabBar.appearance().barTintColor = barColor
        UITabBar.appearance().tintColor = pressedTintColor
        
        let tabBarController = UITabBarController()
        let tabViewController1 = HomeViewController()
        let tabViewController2 = ReportViewController()
        let tabViewController3 = GoalsViewController()
        let tabViewController4 = NotificationViewController()
        
        let controllers = [tabViewController1, tabViewController2, tabViewController3, tabViewController4]
        tabBarController.viewControllers = controllers
        let navigationController = UINavigationController(rootViewController: tabBarController)
        navigationController.navigationBar.barTintColor = UIColor(red: 9/255, green: 37/255, blue: 62/255, alpha: 1.0)
        navigationController.navigationBar.barStyle = UIBarStyle.black

        tabViewController1.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "Home"),
            tag: 1)
        tabViewController2.tabBarItem = UITabBarItem(
            title: "Report",
            image:UIImage(named: "Report") ,
            tag:2)
        tabViewController3.tabBarItem = UITabBarItem(
            title: "Goal",
            image:UIImage(named: "Goals") ,
            tag:2)
        tabViewController4.tabBarItem = UITabBarItem(
            title: "Notification",
            image:UIImage(named: "Notifications") ,
            tag:2)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

