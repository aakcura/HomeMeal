//
//  Customer.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class Customer {
    var name: String?
    var email: String?
    var biography: String?
    var allergies: String?
    var favoriteDishes: [String]?
    var profileImageUrl: String?
    var userId: String?
    var phoneNumber: String?
    var fcmToken: String?
    var accountInfo: AccountInfo?
    
    init(dictionary: [String:Any]) {
        
    }
}
