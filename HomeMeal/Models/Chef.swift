//
//  Chef.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class Chef {
    var name: String?
    var email: String?
    var biography: String?
    var resumeUrl: String?
    var kitchenInformation: KitchenInformation?
    var bestDishes: [String]?
    var profileImageUrl: String?
    var userId: String?
    var phoneNumber: String?
    var fcmToken: String?
    var accountInfo: AccountInfo?
    
    init(dictionary: [String:Any]) {
        
    }
}
