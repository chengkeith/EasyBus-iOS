//
//  AppDelegate.swift
//  EasyBus
//
//  Created by KL on 12/10/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    weak var tabBarController: TabBarViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print(KMBDataManager.shared.busViewModel.count)
        
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = SplashViewController()
        self.window?.makeKeyAndVisible()
        
        let tabBarController = TabBarViewController()
        self.tabBarController = tabBarController
        
        // Version Controll
        APIManager.shared.getAppConfig { (error, serverModel) in
            if let serverModel = serverModel {
                AppManager.shared.config(from: serverModel)
                if AppManager.supportedVersion < serverModel.supportVersion {
                    DispatchQueue.main.async {
                        let alert = SCLAlertView()
                        alert.addButton("前往更新", action: {
                            UIApplication.shared.open(URL(string: serverModel.appLink)!, options: [:], completionHandler: nil)
                        })
                        alert.showInfo(serverModel.updateTitle, subTitle: serverModel.updateMessage, closeButtonTitle: "取消")
                    }
                    return
                }
            }
            if !UserSettingManager.shared.hideTips {
                DispatchQueue.main.async {
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alert = SCLAlertView(appearance: appearance)
                    alert.addButton("不再顯示", action: {
                        UserSettingManager.shared.hideTips = true
                        self.setMainRootView(rootViewController: tabBarController)
                    })
                    alert.addButton("確定", action: {
                        self.setMainRootView(rootViewController: tabBarController)
                    })
                    alert.showInfo("重要提示", subTitle: "如要獲取到站時間，請於App內 -> 設定 -> 關於EasyBus查看")
                }
            }else {
                self.setMainRootView(rootViewController: tabBarController)
            }
        }
        
        // MARK: - Configuration
        
        // Firebase
        FirebaseApp.configure()
        // Google map
        GMSServices.provideAPIKey("AIzaSyDVqKQDrgwa4gSh02RtdHgErfqx0FDqBdU")
        // Push notification
        UIApplication.shared.applicationIconBadgeNumber = 0
        Messaging.messaging().delegate = self
        updatePushToken()
        
        return true
    }
    
    func setMainRootView(rootViewController: UIViewController) {
        DispatchQueue.main.async {
            if let oldRootViewController = self.window?.rootViewController {
                oldRootViewController.present(rootViewController, animated: true, completion: nil)
            }else {
                self.window?.rootViewController = rootViewController
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func updatePushToken() {
        if UserSettingManager.shared.isAllowPush {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound], completionHandler: {(granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                if error != nil {
                    UserSettingManager.shared.isAllowPush = false
                }
            })
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        if url.absoluteString == "easybus://star" {
            self.tabBarController?.selectedIndex = TabBar.starred.rawValue
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
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    // MARK: - UserNotifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Remote notifications token is \(deviceTokenString)")
        if UserSettingManager.shared.isAllowPush {
            APIManager.shared.registerToken(token: deviceTokenString, callback: nil)
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("didReceiveRemoteNotification: ", userInfo)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
