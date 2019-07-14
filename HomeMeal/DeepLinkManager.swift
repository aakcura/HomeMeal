//
//  DeepLinkManager.swift
//  HomeMeal
//
//  Created by Batuhan Abay on 14.07.2019.
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation

enum DeepLinkType{
    enum Messages{
        case root
        case details(id: String)
    }
    case messages(Messages)
    case activity
    case newListing
    case request(id: String)
}

class DeepLinkManager{
    static let shared = DeepLinkManager()
    
    private init() {
        print("Deep Link MAnager initialized")
    }
    
    private var deepLinkType: DeepLinkType?
    
    func checkDeepLink(){
        print("deep link checking")
    }
}
