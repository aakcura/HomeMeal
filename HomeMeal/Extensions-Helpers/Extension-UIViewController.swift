//
//  Extension-UIViewController.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
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
