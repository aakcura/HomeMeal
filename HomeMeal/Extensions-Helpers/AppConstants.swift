//
//  AppConstants.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import Firebase
import Validator

class AppConstants{
    static let usernameAndEmailCharacterCountLimit = 64
    static let passwordMinLength = 6
    static let passwordMaxLength = 32
    static let mealDescriptionCharacterCountLimit = 256
    static let biographyCharacterCountLimit = 512
    static let kitchenAddressDescriptionCharacterCountLimit = 512
    
    static let complaintMessageCharacterCountLimit = 512
    static let instantChatMessageCharacterCountLimit = 2048
    static let lbMessageTitleCharacterCountLimit = 512
    static let lbMessageTextCharacterCountLimit = 2048
    static let lbMessageRegionRadius = 150.0
    static let locationUpdateDistanceFilter = 5.0
    class var currentUserId : String? {
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
    static let userProfileType = "userProfileType"
    static let userSessionId = "userSessionId"
    static let appShareMessage = "appShareMessage"
    static let currentAppVersionNumber = "currentAppVersionNumber"
    static let requiredMinimumAppVersionNumber = "requiredMinimumAppVersionNumber"
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
    var requiredMinimumVersion:String
    var currentVersion:String
    init(values:[String:Any]) {
        self.requiredMinimumVersion = values["requiredMinimumVersion"] as! String
        self.currentVersion = values["currentVersion"] as! String
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

enum AppFontTypes{
    case regularFontAwesome
    case solidFontAwesome
    case brandsFontAwesome
    case system
    case boldSystem
    case italicSystem
}

enum ShortcutKey: String {
    case myProfile = "com.arinakcura.HomeMeal.myProfile"
    case foodList = "com.arinakcura.HomeMeal.foodList"
    case chefOrders = "com.arinakcura.HomeMeal.chefOrders"
}

enum DeepLinkType{
    enum Messages{
        case root
        case details(id: String)
    }
    case messages(Messages)
    case activity
    case newListing
    case request(id: String)
    case chefOrders
    case myProfile
    case foodList
}

enum DBPaths: String{
    case customers = "customers"
    case chefs = "chefs"
    case sessions = "sessions"
}

enum AccountTypeList: String {
    case admin = "admin"
    case customer = "customer"
    case chef = "chef"
}

enum AccountType: Int {
    case admin = 1
    case customer = 2
    case chef = 3
}

enum AccountStatus: Int{
    case disabled = 1
    case enabled = 2
    case pendingApproval = 3
}

enum SessionStatus: Int{
    case passive = 0
    case active = 1
}

enum MealStatus: Int{
    case canNotBeOrdered = 0
    case canBeOrdered = 1
}

enum OrderStatus: Int {
    case received = 1
    case rejected = 2
    case canceled = 3
    case preparing = 4
    case prepared = 5
}


enum MyValidationErrors: String, ValidationError {
    case emptyText = "Empty text"
    case emailInvalid = "Email address is invalid"
    case passwordInvalid = "Password should between 6-32 and not null. Cannot contain whitespace"
    case nameInvalid = "Name boş olamaz"
    case priceInvalid = "Price should be not null numeric value"
    var message: String { return self.rawValue.getLocalizedString() }
}

struct PasswordValidationRule: ValidationRule {
    typealias InputType = String
    var error: ValidationError
    func validate(input: String?) -> Bool {
        guard let input = input else {return false}
        if input != "" && !input.contains(" ") && (input.count >= AppConstants.passwordMinLength && input.count <= AppConstants.passwordMaxLength) {
            return true
        }else{
            return false
        }
    }
}

struct DefaultTextValidationRule: ValidationRule {
    typealias InputType = String
    var error: ValidationError
    func validate(input: String?) -> Bool {
        guard let input = input else {return false}
        if input != "" && !input.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            return true
        }else{
            return false
        }
    }
}

struct PriceValidationRule: ValidationRule {
    typealias InputType = String
    var error: ValidationError
    func validate(input: String?) -> Bool {
        guard let input = input else {return false}
        if input != "", let _ = Double.init(input){
            return true
        }else{
            return false
        }
    }
}


