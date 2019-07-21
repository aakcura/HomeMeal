//
//  ShortcutParser.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

class ShortcutParser {
    static let shared = ShortcutParser()
    private init(){}
    
    func handleShortcut(_ shortcut: UIApplicationShortcutItem) -> DeepLinkType? {
        switch shortcut.type {
        case ShortcutKey.chefOrders.rawValue:
            return .chefOrders
        case ShortcutKey.myProfile.rawValue:
            return .myProfile
        case ShortcutKey.foodList.rawValue:
            return .foodList
        default:
            return nil
        }
    }
    
    ///This method register shortcuts item when application opened but we can register shortcuts from info.plist
    func registerShortcuts(for profileType: AccountTypeList) {
        let myProfileIcon = UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.contact)
        let myProfileShortcutItem = UIApplicationShortcutItem(type: ShortcutKey.myProfile.rawValue, localizedTitle: "My Profile", localizedSubtitle: nil, icon: myProfileIcon, userInfo: nil)
        
        let foodListIcon = UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.home)
        let foodListShortcutItem = UIApplicationShortcutItem(type: ShortcutKey.foodList.rawValue, localizedTitle: "Food List", localizedSubtitle: nil, icon: foodListIcon, userInfo: nil)
        
        //let chefOrdersIcon = UIApplicationShortcutIcon(templateImageName: "Messenger Icon")
        let chefOrdersIcon = UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.alarm)
        let chefOrdersShortcutItem = UIApplicationShortcutItem(type: ShortcutKey.chefOrders.rawValue, localizedTitle: "Chef Orders", localizedSubtitle: nil, icon: chefOrdersIcon, userInfo: nil)
        
        UIApplication.shared.shortcutItems = [myProfileShortcutItem]
        
        switch profileType {
        case .chef:
            UIApplication.shared.shortcutItems?.append(chefOrdersShortcutItem)
            break
        case .customer:
            UIApplication.shared.shortcutItems?.append(foodListShortcutItem)
            break
        case .admin:
            break
        }
    }
    
}
