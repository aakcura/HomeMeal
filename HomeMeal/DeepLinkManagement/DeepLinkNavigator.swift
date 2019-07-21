//
//  DeepLinkNavigator.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

class DeepLinkNavigator {
    static let shared = DeepLinkNavigator()
    private init() {}
    
    func proceedToDeepLink(_ type: DeepLinkType){
        print("proceedToDeepLink with type=\(type)")
        switch type {
        case .activity:
            displayAlert(title: "Activity")
        case .messages(.root):
            displayAlert(title: "Messages Root")
        case .messages(.details(id: let id)):
            displayAlert(title: "Messages Details \(id)")
        case .newListing:
            displayAlert(title: "New Listing")
        case .request(id: let id):
            displayAlert(title: "Request Details \(id)")
        case .chefOrders:
            displayAlert(title: "Chef ORders")
        case .myProfile:
            displayAlert(title: "My Profile")
        case .foodList:
            displayAlert(title: "Food List")
        }
    }
    
    private var alertController = UIAlertController()
    private func displayAlert(title: String) {
        alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okButton)
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            if vc.presentedViewController != nil {
                alertController.dismiss(animated: false, completion: {
                    vc.present(self.alertController, animated: true, completion: nil)
                })
            } else {
                vc.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
}
