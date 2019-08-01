//
//  AppDelegate.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let gcmMessageIDKey = "gcm.message_id"
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupFirebase()
        setupNavBarTheme()
        setupIQKeyboardManager()
        
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
        // [END register_for_notifications]
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        //let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestNavigationController") as? UINavigationController
        //window?.rootViewController = vc
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
        
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
        
        //handle any deeplink
        DeepLinkManager.shared.checkDeepLink()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // MARK: Shortcuts
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(DeepLinkManager.shared.handleShortcut(item: shortcutItem))
    }
    
    
    // MARK: Deeplinks - homemeal://....
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return DeepLinkManager.shared.handleDeepLink(url: url)
    }
    // MARK: Universal Links
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                return DeepLinkManager.shared.handleDeepLink(url: url)
            }
        }
        return false
    }
   
    // MARK: Notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        /*
         This method will also be triggered when the app received a push notification while it is running in the foreground mode. Because we only considering the scenarios when you want to open the app on the certain page, we will not cover handling notifications in the foreground mode.
         */
        DeepLinkManager.shared.handleRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    

}

// Custom MEthods
extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate{
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var rootViewController: RootViewController {
        return window!.rootViewController as! RootViewController
    }
    
    static var storyboard: UIStoryboard {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
    
    /// Firebase setup.
    func setupFirebase(){
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        Messaging.messaging().delegate = self
    }
    
    /// Sets application navigation bar theme.
    func setupNavBarTheme(){
        //NAvigation bar rengini değiştirdik
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = AppColors.navBarTintColor //left ve right button rengini belirtir
        navigationBarAppearance.barTintColor = AppColors.navBarBackgroundColor //background rengini belirtir
        let textAttributes = [NSAttributedString.Key.foregroundColor:AppColors.navBarTitleColor]
        navigationBarAppearance.titleTextAttributes = textAttributes // navbar title textinin attributelarını belirtir
        navigationBarAppearance.isTranslucent = false
    }
    
    /// IQKeyboardManager bağlantı ayarları
    func setupIQKeyboardManager(){
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true //kalvye üstünde açılan toolbar ı açar/kapatır
        //IQKeyboardManager.shared.overrideKeyboardAppearance = true //klave görünümünü değiştirmemizi sağlar
        //IQKeyboardManager.shared.keyboardAppearance = .dark //kalvye görünümünü siyah yapar
        //IQKeyboardManager.shared.keyboardDistanceFromTextField = 100 //textfield ile açılan klavye arasındaki uzaklıktır defauşt ta 10 dur
        //IQKeyboardManager.shared.toolbarBarTintColor = .red
        //IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Hide Keyboard"
        IQKeyboardManager.shared.toolbarDoneBarButtonItemImage = AppIcons.angleDown
        //IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true //default is true
        //IQKeyboardManager.shared.placeholderFont = UIFont(name: "Times New Roman", size: 15.0)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true //textview veya textfield dışında biryere tıklanınca keyboardu dismiss etmeye yarar
        IQKeyboardManager.shared.shouldPlayInputClicks = false //default is true bu ayar textfieldlar arasında geçis yaparken ses çıkmasına yarar
    }
    
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        //print("Firebase registration token: \(fcmToken)")
        UserDefaults.standard.set(fcmToken, forKey: UserDefaultsKeys.firebaseNotificationToken)
        //let dataDict:[String: String] = ["token": fcmToken]
        //NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    
}
