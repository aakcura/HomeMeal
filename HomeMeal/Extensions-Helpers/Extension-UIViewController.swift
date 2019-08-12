//
//  Extension-UIViewController.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    func addNetworkStatusListener(){
        NetworkManager.sharedInstance.reachability.whenUnreachable = { reach in
            DispatchQueue.main.async {
                let connectionLostVC = ConnectionLostVC()
                self.present(connectionLostVC, animated: true, completion: nil)
            }
        }
    }

    func removeNavBarBackButtonText(){
        let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtton
    }
    
    func setNavBarTitle(_ title:String, withAttributes titleAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor:UIColor.white]){
        self.navigationItem.title = title
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
    }
    
    func hideNavBar(_ shouldHide:Bool, animated: Bool){
        navigationController?.setNavigationBarHidden(shouldHide, animated: animated)
    }
}
