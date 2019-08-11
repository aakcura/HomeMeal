//
//  SocialAccounts.swift
//  HomeMeal
//
//  Created by Batuhan Abay on 7.08.2019.
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

enum SocialAccountType: String {
    case instagram = "instagram"
    case linkedin = "linkedin"
    case pinterest = "pinterest"
    case twitter = "twitter"
}

class SocialAccountsBaseUrl {
    private static let baseURLDictionary = [
        SocialAccountType.instagram: "https://www.instagram.com/",
        SocialAccountType.linkedin: "https://www.linkedin.com/in/",
        SocialAccountType.pinterest: "https://pinterest.com/",
        SocialAccountType.twitter: "https://twitter.com/"
    ]
    static func getBaseUrl(by socialAccountType: SocialAccountType) -> URL{
        let baseUrlString = baseURLDictionary[socialAccountType]!
        return URL(string: baseUrlString)!
    }
}

class SocialAccount{
    var accountType: SocialAccountType
    var userName: String
    var url: URL
    
    init(accountTypeName:String, userName:String) {
        self.accountType = SocialAccountType(rawValue: accountTypeName)!
        self.userName = userName
        let  baseURL = SocialAccountsBaseUrl.getBaseUrl(by: accountType)
        self.url = baseURL.appendingPathComponent(userName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
    }
}
