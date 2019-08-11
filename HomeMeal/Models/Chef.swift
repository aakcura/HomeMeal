//
//  Chef.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class Chef {
    var bestMeals: [String]?
    var biography: String?
    var email: String
    var fcmToken: String?
    var kitchenInformation: KitchenInformation
    var name: String
    var phoneNumber: String
    var profileImageUrl: String?
    var rating: Double
    var socialAccounts: [SocialAccount]?
    var userId: String
    
    init(dictionary: [String:Any]) {
        self.bestMeals = dictionary["bestMeals"] as? [String]
        self.biography = dictionary["biography"] as? String
        self.email = dictionary["email"] as! String
        self.fcmToken = dictionary["fcmToken"] as? String
        
        let kitchenInformationDictionary = dictionary["kitchenInformation"] as! [String:AnyObject]
        self.kitchenInformation = KitchenInformation(dictionary: kitchenInformationDictionary)
        
        self.name = dictionary["name"] as! String
        self.phoneNumber = dictionary["phoneNumber"] as! String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.rating = dictionary["rating"] as? Double ?? 0.0
        if let socialAccountsDictionary = dictionary["socialAccounts"] as? [String:String]{
            var socialAccountList = [SocialAccount]()
            for item in socialAccountsDictionary {
                let socialAccount = SocialAccount(accountTypeName: item.key, userName: item.value)
                socialAccountList.append(socialAccount)
            }
            self.socialAccounts = socialAccountList.count > 0 ? socialAccountList : nil
        }
        self.userId = dictionary["userId"] as! String
    }
    
    func hasBestMeal() -> Bool {
        if self.bestMeals != nil && self.bestMeals!.count > 0 {
            return true
        }else{
            return false
        }
    }
    
    func hasBiography() -> Bool {
        return self.biography != nil
    }
    
    func hasProfileImage() -> Bool {
        return self.profileImageUrl != nil
    }
    
    func hasSocialAccounts() -> Bool {
        if self.socialAccounts != nil && self.socialAccounts!.count > 0 {
            return true
        }else{
            return false
        }
    }
}
