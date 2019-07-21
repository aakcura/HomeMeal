//
//  DeepLinkManager.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

class DeepLinkManager{
    static let shared = DeepLinkManager()
    
    private init() {
        print("Deep Link MAnager initialized")
    }
    
    private var deepLinkType: DeepLinkType?
    
    // check existing deepling and perform action
    func checkDeepLink(){
        print("deep link checking")
        guard let deeplinkType = deepLinkType else {
            print("NO DEEPLİNK")
            return
        }
        AppDelegate.shared.rootViewController.deepLink = deeplinkType
        print("DEEP LİNK TYPE = \(deepLinkType)")
        // reset deeplink after handling
        self.deepLinkType = nil // (1)
    }
    
    //@discardableResult tells the compiler to ignore the result value if we don't use it, so we don't have an “unused result” warning
    @discardableResult
    func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
        deepLinkType = ShortcutParser.shared.handleShortcut(item)
        return deepLinkType != nil
    }
    
    @discardableResult
    func handleDeepLink(url: URL) -> Bool {
        deepLinkType = DeepLinkParser.shared.parseDeepLink(url)
        return deepLinkType != nil
    }
    
    
    func handleRemoteNotification(_ notification: [AnyHashable: Any]) {
        deepLinkType = NotificationParser.shared.handleNotification(notification)
    }
    
}
