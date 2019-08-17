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
        AppStoreReviewHelper.checkAndAskForReview()
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
        setupTabBarViewControllers()
    }
    
    private func setupTabBarViewControllers(){
        
        let customerOrdersVC = CustomerOrdersVC()
        let ordersVCNavController = UINavigationController(rootViewController: customerOrdersVC)
        customerOrdersVC.tabBarItem.title = "My Orders".getLocalizedString()
        customerOrdersVC.tabBarItem.image = AppIcons.ordersIcon
        
        let customerMealListVC = CustomerMealListVC()
        let customerMealListVCNavController = UINavigationController(rootViewController: customerMealListVC)
        customerMealListVC.tabBarItem.title = "Meal List".getLocalizedString()
        customerMealListVC.tabBarItem.image = AppIcons.cutleryIcon
        
        let customerProfileVC = CustomerProfileVC()
        let customerProfileVCWithNav = UINavigationController(rootViewController: customerProfileVC)
        customerProfileVC.tabBarItem.title = "Profile".getLocalizedString()
        customerProfileVC.tabBarItem.image = AppIcons.profileIcon
        
        viewControllers = [ordersVCNavController,customerMealListVCNavController,customerProfileVCWithNav]
    }

}
