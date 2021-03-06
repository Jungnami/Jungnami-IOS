//
//  AppDelegate.swift
//  Jungnami
//
//  Created by 강수진 on 2018. 7. 1..
//  Copyright © 2018년 강수진. All rights reserved.
//


//kakaoTalk
enum LoginType {
    case kakao
    case local
}

var loginWith : LoginType!


import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate  {

    var window: UIWindow?
    var loginVC: UIViewController?
    var tabbarVC : UIViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //파이어베이스 설정
            FirebaseApp.configure()
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        //카카오 시작
        setupEntryController()
        setupPushNotification()
        
        // 로그인,로그아웃 상태 변경 받기
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(AppDelegate.kakaoSessionDidChangeWithNotification),
                                               name: NSNotification.Name.KOSessionDidChange,
                                               object: nil)
        
        
       
        reloadRootViewController()
        
        
        //kakao
        let isOpened = KOSession.shared().isOpen()
        if  isOpened {loginWith = .kakao}
        
        //카카오 끝
       
        UITabBar.appearance().tintColor = UIColor(red: CGFloat(54/255.0), green: CGFloat(197/255.0), blue: CGFloat(241/255.0), alpha: CGFloat(1.0) )
    
  
        return true
    }
    
    // fcmToken
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
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
    
    //카카오 시작
    fileprivate func setupEntryController() {
        let mainStoryboard = Storyboard.shared().mainStoryboard
        let rankStoryboard = Storyboard.shared().rankStoryboard
      
        
        self.loginVC = rankStoryboard.instantiateViewController(withIdentifier: LoginVC.reuseIdentifier) as! LoginVC
        self.tabbarVC = mainStoryboard.instantiateViewController(withIdentifier: "tabBar") 
    
        
    }

    
     func reloadRootViewController() {
        
        /*let splashVC = Storyboard.shared().mainStoryboard.instantiateViewController(withIdentifier: SplashVC.reuseIdentifier) as? SplashVC
        
        self.window?.rootViewController = splashVC
        splashVC?.finishLaunchScreenHandler = {(_) in self.selectRootView()}*/
        selectRootView()
    }
    
    func selectRootView(){
        let isOpened = KOSession.shared().isOpen()
        if !isOpened {
            self.window?.rootViewController = loginVC
        }
        self.window?.rootViewController = isOpened ? self.tabbarVC : self.loginVC
        self.window?.makeKeyAndVisible()
        if isOpened && !UserDefaults.standard.bool(forKey: "alreadyShownInfo"){
            let infoVC = Storyboard.shared().rankStoryboard.instantiateViewController(withIdentifier: InfoVC.reuseIdentifier)
            self.window?.rootViewController?.present(infoVC, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "alreadyShownInfo")
        }
    }
    
    @objc func kakaoSessionDidChangeWithNotification() {
        reloadRootViewController()
    }
    func setupPushNotification() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if let error = error as NSError? {
                print("APNS Authorization failure. \(error)")
            } else {
                print("APNS Authorization success.")
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("The notification \"\(notification.request.identifier)\" is presenting. \"\(notification.request.content.body)\"")
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("The user responded to the notification \"\(response.notification.request.identifier)\" at \"\(response.notification.date.description(with: .current))\".")
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.handleOpen(url) {
            return true
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if KOSession.handleOpen(url) {
            return true
        }
        return false
    }
    //카카오 끝

}

