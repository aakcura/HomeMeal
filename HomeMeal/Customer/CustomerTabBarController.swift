//
//  CustomerTabBarController.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class CustomerTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
        getCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideNavBar(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideNavBar(true, animated: animated)
    }
    
    private func getCurrentUser(){
        guard let currentUserId = AppConstants.currentUserId else {return}
        Database.database().reference().child("customers").child(currentUserId).observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let currentCustomer = Customer(dictionary: dictionary)
                AppDelegate.shared.currentUserAsCustomer = currentCustomer
            }
        }
    }
    
    private func setupUIProperties(){
        self.tabBar.isTranslucent = false
        setupTabBarViewControllers()
    }
    
    private func setupTabBarViewControllers(){
        let mainVC = MainVC()
        let mainVCWithNav = UINavigationController(rootViewController: mainVC)
        mainVC.tabBarItem.title = "Profile".getLocalizedString()
        mainVC.tabBarItem.image = AppIcons.profileIcon
        
        viewControllers = [mainVCWithNav]
    }

}
