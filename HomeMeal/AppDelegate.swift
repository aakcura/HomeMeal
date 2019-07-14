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
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestViewController") as? TestViewController
        
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


}

// Custom MEthods
extension AppDelegate{
    
    /// Firebase setup.
    func setupFirebase(){
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        //Messaging.messaging().delegate = self
    }
    
    /// Sets application navigation bar theme.
    func setupNavBarTheme(){
        //NAvigation bar rengini değiştirdik
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = .white //left ve right button rengini belirtir
        navigationBarAppearace.barTintColor = AppColors.navBarBlueColor //background rengini belirtir
        navigationBarAppearace.isTranslucent = false
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
}
