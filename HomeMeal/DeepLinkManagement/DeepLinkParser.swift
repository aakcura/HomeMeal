//
//  DeepLinkParser.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

class DeepLinkParser {
    static let shared = DeepLinkParser()
    private init(){}
    
    func parseDeepLink(_ url: URL) -> DeepLinkType? {
        /*
         Note, that this parsing method will depend on your deeplinks structure, and my solution is only an example.
         homemeal://messages/1
         homemeal://request/1
         */
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }
        var pathComponents = components.path.components(separatedBy: "/")
        // the first component is empty
        pathComponents.removeFirst()
        switch host {
        case "messages":
            if let messageId = pathComponents.first {
                return DeepLinkType.messages(.details(id: messageId))
            }
        case "request":
            if let requestId = pathComponents.first {
                return DeepLinkType.request(id: requestId)
            }
        case "activity":
            return DeepLinkType.activity
        default:
            break
        }
        return nil
    }
}
