//
//  AppConstants.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import Firebase

class AppConstants{
    static let complaintMessageCharacterCountLimit = 512
    static let usernameCharacterCountLimit = 64
    static let instantChatMessageCharacterCountLimit = 2048
    static let lbMessageTitleCharacterCountLimit = 512
    static let lbMessageTextCharacterCountLimit = 2048
    static let lbMessageRegionRadius = 150.0
    static let locationUpdateDistanceFilter = 5.0
    class var authenticatedUserId : String? {
        get{
            if let currentUser = Auth.auth().currentUser {
                return currentUser.uid
            }else{
                return nil
            }
        }
    }
}

class UserDefaultsKeys{
    static let appOpenedCount = "appOpenedCount"
    static let isRegisteredUser = "isRegisteredUser"
    static let appShareMessage = "appShareMessage"
    static let appVersionNumber = "appVersionNumber"
    static let leastNeededAppVersionNumber = "leastNeededAppVersionNumber"
    static let firebaseNotificationToken = "firebaseNotificationToken"
    static let didWalkthroughScreenShownBefore = "didWalkthroughScreenShownBefore"
}

class NotificationNames{
    static let friendUpdatedNotificationName = Notification.Name("friendUpdatedNotificationName")
    static let stopAllRegionTrackingActivitiesNotificationName = Notification.Name("stopAllRegionTrackingActivitiesNotificationName")
    static let regionMonitoringStatusChangedNotificationName = Notification.Name("regionMonitoringStatusChangedNotificationName")
}

class DeviceOSTypes{
    static let android : String = "android";
    static let ios : String = "ios";
}

struct AppVersionInfo {
    var leastNeededVersion:String
    var version:String
    init(values:[String:Any]) {
        self.leastNeededVersion = values["leastNeededVersion"] as! String
        self.version = values["version"] as! String
    }
}


class FontAwesomeFonts {
    static let regular = UIFont(name: FontAwesomeFontNames.regular.rawValue, size: UIFont.labelFontSize)!
    static let solid = UIFont(name: FontAwesomeFontNames.solid.rawValue, size: UIFont.labelFontSize)!
    static let brands = UIFont(name: FontAwesomeFontNames.brands.rawValue, size: UIFont.labelFontSize)!
}

enum FontAwesomeFontNames : String {
    case regular = "FontAwesome5Free-Regular"
    case solid = "FontAwesome5Free-Solid"
    case brands = "FontAwesome5Brands-Regular"
}

/*FONTAWESOME
 guard let customFont = UIFont(name: "FontAwesome5Free-Regular", size: UIFont.labelFontSize) else {
 fatalError("""
 Failed to load the "CustomFont-Light" font.Make sure the font file is included in the project and the font name is spelled correctly.
 """
 )
 }
 
 
 
 enum FontAwesomeFontTypes: String {
 case Regular: "FontAwesome5Free-Regular"
 case
 }
 
 button.setTitle("", for: .normal)
 
 label.font = UIFontMetrics.default.scaledFont(for: customFont)
 label.adjustsFontForContentSizeCategory = true
 label.text = "\t\tResume"
 
 label.font = UIFont.init(name: "FontAwesome5Free-Regular", size: 30)
 
 
 Family: Font Awesome 5 Brands Font names: ["FontAwesome5Brands-Regular"]
 Family: Font Awesome 5 Free Font names: ["FontAwesome5Free-Solid", "FontAwesome5Free-Regular"]
 guard let customFont = UIFont(name: "FontAwesome5Free-Regular", size: UIFont.labelFontSize) else {
 fatalError("""
 Failed to load the "CustomFont-Light" font.Make sure the font file is included in the project and the font name is spelled correctly.
 """
 )
 }
 
 */
