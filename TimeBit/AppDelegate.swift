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

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.tintColor = UIColor.white
        UITabBar.appearance().barTintColor = UIColor(red: 0.02, green: 0.09, blue: 0.17, alpha: 1.0)
        UITabBar.appearance().tintColor = UIColor.white
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        
        let tabBarController = UITabBarController()
        let tabViewController1 = UINavigationController(rootViewController: HomeViewController())
        let tabViewController2 = UINavigationController(rootViewController: ReportViewController())
        let tabViewController3 = UINavigationController(rootViewController: GoalsViewController())
        let tabViewController4 = UINavigationController(rootViewController: NotificationViewController())
        
        let controllers = [tabViewController1, tabViewController2, tabViewController3, tabViewController4]
        tabBarController.viewControllers = controllers
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = UIColor(red: 0.02, green: 0.09, blue: 0.17, alpha: 1.0)
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]

        tabViewController1.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "Home"),
            tag: 1)
        tabViewController2.tabBarItem = UITabBarItem(
            title: "Report",
            image:UIImage(named: "Report") ,
            tag:2)
        tabViewController3.tabBarItem = UITabBarItem(
            title: "Goals",
            image:UIImage(named: "Goals") ,
            tag:2)
        tabViewController4.tabBarItem = UITabBarItem(
            title: "Notification",
            image:UIImage(named: "Notifications") ,
            tag:2)
        
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
    
    // This method will be called when app received push notifications in foreground
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler(UNNotificationPresentationOptions.alert)
//    }
    
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        
//        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
//        print(deviceTokenString)
//        
//        UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
//            
//            switch setttings.soundSetting{
//            case .enabled:
//                
//                print("enabled sound setting")
//                
//            case .disabled:
//                
//                print("setting has been disabled")
//                
//            case .notSupported:
//                print("something vital went wrong here")
//            }
//        }
//
//        
//        
//    }
//    
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        
//        print("i am not available in simulator \(error)")
//        
//    }
//    
//    
//    
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        
//    }


}

