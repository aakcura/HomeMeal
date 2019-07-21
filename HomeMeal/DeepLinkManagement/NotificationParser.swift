//
//  NotificationParser.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

class NotificationParser {
    static let shared = NotificationParser()
    private init(){}
    
    func handleNotification(_ userInfo: [AnyHashable : Any]) -> DeepLinkType? {
        if let data = userInfo["data"] as? [String: Any] {
            if let messageId = data["messageId"] as? String {
                return DeepLinkType.messages(.details(id: messageId))
            }
        }
        return DeepLinkType.messages(.details(id: "test"))
    }
    
}
