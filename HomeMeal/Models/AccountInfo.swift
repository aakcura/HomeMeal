//
//  Chef.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

class AccountInfo{
    var accountType: AccountType?
    var status: AccountStatus?
    var creationDate: Date?
    
    init(dictionary: [String: Any]) {
        if let accountTypeNumber = dictionary["accountType"] as? Int{
            self.accountType = AccountType(rawValue: accountTypeNumber)
        }
        
        if let status = dictionary["status"] as? Int{
            self.status = AccountStatus(rawValue: status)
        }
        
        if let creationTimeInterval = dictionary["creationDate"] as? TimeInterval {
            self.creationDate = Date(timeIntervalSince1970: creationTimeInterval)
        }
    }
}
