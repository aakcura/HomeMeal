//
//  Customer.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class Customer {
    var allergies: [String]?
    var biography: String?
    var email: String
    var favoriteMeals: [String]?
    var fcmToken: String?
    var name: String
    var phoneNumber: String
    var profileImageUrl: String?
    var socialAccounts: [SocialAccount]?
    var userId: String
    
    init(dictionary: [String:Any]) {
        self.allergies = dictionary["allergies"] as? [String]
        self.biography = dictionary["biography"] as? String
        self.email = dictionary["email"] as! String
        self.favoriteMeals = dictionary["favoriteMeals"] as? [String]
        self.fcmToken = dictionary["fcmToken"] as? String
        self.name = dictionary["name"] as! String
        self.phoneNumber = dictionary["phoneNumber"] as! String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
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
    
    func hasAllergy() -> Bool {
        if self.allergies != nil && self.allergies!.count > 0 {
            return true
        }else{
            return false
        }
    }
    
    func hasBiography() -> Bool {
        return self.biography != nil
    }

    func hasFavoriteMeal() -> Bool {
        if self.favoriteMeals != nil && self.favoriteMeals!.count > 0 {
            return true
        }else{
            return false
        }
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
    
    // TO DO: Write getDictionary() method
}
