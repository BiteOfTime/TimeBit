//
//  AppDelegate.swift
//  TimeBit
//
//  Created by Krishna Alex on 4/24/17.
//  Copyright © 2017 BiteOfTime. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    public static let goingInBackground = NSNotification.Name(rawValue: "GoingInBackground")
    public static let comingToForeground = NSNotification.Name(rawValue: "ComingToForeground")
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.tintColor = UIColor.black
        UIApplication.shared.statusBarStyle = .lightContent
        
        let tabBarController = UITabBarController()
        tabBarController.tabBar.isTranslucent = false
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.barTintColor = UIColor(red: 4/255, green: 23/255, blue: 44/255, alpha: 1.0)
        tabBarAppearance.tintColor = UIColor.white
        tabBarController.tabBar.layer.shadowOffset = CGSize(width:0, height: 0)
        tabBarController.tabBar.layer.shadowRadius = 20
        tabBarController.tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBarController.tabBar.layer.shadowOpacity = 0.8
        
        let tabViewController1 = UINavigationController(rootViewController: HomeViewController())
        let tabViewController2 = UINavigationController(rootViewController: ReportGraphViewController())
        let tabViewController3 = UINavigationController(rootViewController: GoalsViewController())
        let tabViewController4 = UINavigationController(rootViewController: NotificationViewController())
        
        let controllers = [tabViewController1, tabViewController2, tabViewController3, tabViewController4]
        tabBarController.viewControllers = controllers
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.isTranslucent = false
        navigationBarAppearace.barTintColor = UIColor(red: 4/255, green: 23/255, blue: 44/255, alpha: 1.0)
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navigationBarAppearace.tintColor = .white
        
        tabViewController1.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Home"),
            tag: 1)
        tabViewController1.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        tabViewController2.tabBarItem = UITabBarItem(
            title: "",
            image:UIImage(named: "Report") ,
            tag:2)
        tabViewController2.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        tabViewController3.tabBarItem = UITabBarItem(
            title: "",
            image:UIImage(named: "Goals") ,
            tag:3)
        tabViewController3.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        tabViewController4.tabBarItem = UITabBarItem(
            title: "",
            image:UIImage(named: "Notifications") ,
            tag:4)
        tabViewController4.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white
            window.rootViewController = tabBarController
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
        NotificationCenter.default.post(Notification(name: AppDelegate.goingInBackground))
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NotificationCenter.default.post(Notification(name: AppDelegate.comingToForeground))
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}
