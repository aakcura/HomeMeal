//
//  ChefTabBarController.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class ChefTabBarController: UITabBarController {

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
        Database.database().reference().child("chefs").child(currentUserId).observe(.value) { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject]{
                let currentChef = Chef(dictionary: dictionary)
                AppDelegate.shared.currentUserAsChef = currentChef
            }
        }
    }
    
    private func setupUIProperties(){
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = AppColors.navBarBackgroundColor
        setupTabBarViewControllers()
    }
    
    private func setupTabBarViewControllers(){
       
        let ordersVC = ChefOrdersVC()
        let ordersVCNavController = UINavigationController(rootViewController: ordersVC)
        ordersVC.tabBarItem.title = "Orders".getLocalizedString()
        ordersVC.tabBarItem.image = AppIcons.ordersIcon
        
        let menuVC = ChefMenuVC()
        let menuVCNavController = UINavigationController(rootViewController: menuVC)
        menuVC.tabBarItem.title = "Menu".getLocalizedString()
        menuVC.tabBarItem.image = AppIcons.cutleryIcon
        
        let mainVC = MainVC()
        let mainVCWithNav = UINavigationController(rootViewController: mainVC)
        mainVC.tabBarItem.title = "Profile".getLocalizedString()
        mainVC.tabBarItem.image = AppIcons.profileIcon
        
        viewControllers = [ordersVCNavController, menuVCNavController, mainVCWithNav]
    }

}
