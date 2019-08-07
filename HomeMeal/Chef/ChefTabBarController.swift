//
//  ChefTabBarController.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class ChefTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        self.tabBar.isTranslucent = false
        setupTabBarViewControllers()
    }
    
    private func setupTabBarViewControllers(){
        //        let instantVCNavigationController = UINavigationController(rootViewController: InstantVC())
        //        instantVCNavigationController.tabBarItem.title = "Chat".getLocalizedString()
        //        instantVCNavigationController.tabBarItem.image = AppIcons.chats
        //
        //        let mapBoxController = MapBoxVC()
        //        mapBoxController.tabBarItem.title = "Map".getLocalizedString()
        //        mapBoxController.tabBarItem.image = AppIcons.map
        //
        //        let newMessageVCNavigationController = UINavigationController(rootViewController: NewMessageVC())
        //        newMessageVCNavigationController.tabBarItem.title = "New Message".getLocalizedString()
        //        newMessageVCNavigationController.tabBarItem.image = AppIcons.newMessage
        //
        //        let friendsVCNavigationController = UINavigationController(rootViewController: FriendsVC())
        //        friendsVCNavigationController.tabBarItem.title = "Friends".getLocalizedString()
        //        friendsVCNavigationController.tabBarItem.image = AppIcons.friends
        //
        //        let profileController = sb.instantiateViewController(withIdentifier: "ProfileController") as! ProfileController
        //        let profileVCNavigationController = UINavigationController(rootViewController: profileController)
        //        profileVCNavigationController.tabBarItem.title = "Profile".getLocalizedString()
        //        profileVCNavigationController.tabBarItem.image = AppIcons.profile
        //
        //        viewControllers = [instantVCNavigationController, mapBoxController, newMessageVCNavigationController, friendsVCNavigationController, profileVCNavigationController]
    }

}
