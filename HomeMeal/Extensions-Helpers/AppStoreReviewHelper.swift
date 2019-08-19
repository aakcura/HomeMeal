//
//  AppStoreReviewHelper.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import StoreKit

struct AppStoreReviewHelper {
    /// Increment app opened count on user defaults for counting app opened and show user app rating review. Called from maintabbar controller.
    static func incrementAppOpenedCount() {
        guard var appOpenCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.appOpenedCount) as? Int else {
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.appOpenedCount)
            return
        }
        appOpenCount += 1
        print(appOpenCount)
        UserDefaults.standard.set(appOpenCount, forKey: UserDefaultsKeys.appOpenedCount)
    }
    
    /// Checks app opened count and shows app rating review to user when app count is 10/50/100th
    static func checkAndAskForReview() {
        guard let appOpenCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.appOpenedCount) as? Int else {
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.appOpenedCount)
            return
        }
        
        switch appOpenCount {
        case 10,50:
            AppStoreReviewHelper().requestReview()
        case _ where appOpenCount%100 == 0 :
            AppStoreReviewHelper().requestReview()
        default:
            //print("APP OPENED COUNT = \(appOpenCount)")
            break;
        }
    }
    
    fileprivate func requestReview() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
    }
}
