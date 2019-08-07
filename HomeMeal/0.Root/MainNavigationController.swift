//
//  MainNavigationController.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class MainNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUserId = AppConstants.currentUserId {
            Crashlytics.sharedInstance().setUserIdentifier(currentUserId)
        }
        AppStoreReviewHelper.incrementAppOpenedCount()
        registerFCMNotificationTokenToUserAccount()
        checkAppVersionInformation()
    }
    
    private func checkAppVersionInformation(){
        if NetworkManager.isConnectedNetwork() {
            Database.database().reference().child("appVersionInfo/iOS").observe(.value) { [weak self] (snapshot) in
                if let values = snapshot.value as? [String:AnyObject] {
                    let appVersionInfo = AppVersionInfo(values: values)
                    UserDefaults.standard.set(appVersionInfo.currentVersion, forKey: UserDefaultsKeys.currentAppVersionNumber)
                    UserDefaults.standard.set(appVersionInfo.requiredMinimumVersion, forKey: UserDefaultsKeys.requiredMinimumAppVersionNumber)
                    if let localAppVersionNumber = DeviceAndAppInfo().applicationVersionNumber{
                        if localAppVersionNumber.compare(appVersionInfo.currentVersion, options: .numeric, range: nil, locale: nil) == .orderedAscending {
                            if localAppVersionNumber.compare(appVersionInfo.requiredMinimumVersion, options: .numeric, range: nil, locale: nil) == .orderedAscending{
                                self?.blockUIWithUpdateAlert()
                            }else{
                                self?.showUpdateAlert()
                            }
                        }
                    }
                }
            }
        }else{
            if let localAppVersion = DeviceAndAppInfo().applicationVersionNumber, let requiredMinimumAppVersion = UserDefaults.standard.string(forKey: UserDefaultsKeys.requiredMinimumAppVersionNumber), let currentAppVersion = UserDefaults.standard.string(forKey: UserDefaultsKeys.currentAppVersionNumber) {
                if localAppVersion.compare(currentAppVersion, options: .numeric, range: nil, locale: nil) == .orderedAscending {
                    if localAppVersion.compare(requiredMinimumAppVersion, options: .numeric, range: nil, locale: nil) == .orderedAscending{
                        blockUIWithUpdateAlert()
                    }else{
                        showUpdateAlert()
                    }
                }
            }
        }
    }
    
    private func blockUIWithUpdateAlert(){
        DispatchQueue.main.async { [weak self] in
            self?.present(AlertService.getAlert(message: "AppUpdateNeededMessage".getLocalizedString(), blockUI: true), animated: true, completion: nil)
        }
    }
    
    private func showUpdateAlert(){
        DispatchQueue.main.async { [weak self] in
            self?.present(AlertService.getAlert(message: "AvailableUpdateMessage".getLocalizedString(), title: "New Version Released".getLocalizedString()), animated: true, completion: nil)
        }
    }
    
    private func registerFCMNotificationTokenToUserAccount(){
        if let fcmToken = UserDefaults.standard.value(forKey: UserDefaultsKeys.firebaseNotificationToken) as? String, let userId = AppConstants.currentUserId, let accountType = AppDelegate.shared.currentUserAccountType{
            if NetworkManager.isConnectedNetwork() {
                var path = ""
                if accountType == .chef {
                    path = "chefs"
                }else if accountType == .customer {
                    path = "customers"
                }
                
                if path != "" {
                    Database.database().reference().child(path).child(userId).updateChildValues(["fcmToken":fcmToken])
                }
            }
        }
    }

}
