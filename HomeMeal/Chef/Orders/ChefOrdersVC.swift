//
//  ChefOrdersVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class ChefOrdersVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
    }
    
    private func setupUIProperties(){
        view.backgroundColor = .white
        customizeNavBar()
        addActivityIndicatorToView()
    }
    
    private func customizeNavBar(){
        setNavBarTitle("Incoming Orders".getLocalizedString())
        let btnShowPastOrders = UIBarButtonItem(image: AppIcons.listWhiteIcon, style: .plain, target: self, action: #selector(showPastOrders))
        //UIBarButtonItem.init(image: AppIcons.plusWhiteIcon, style: .plain, target: self, action: #selector(goPrepareMealScreen))
        self.navigationItem.rightBarButtonItems = [btnShowPastOrders]
        //self.navigationItem.leftBarButtonItems = [myProfileBarButton]
        //let logoutButton = UIBarButtonItem.init(image: AppIcons.logoutIcon, style: .plain, target: self, action: #selector(logoutButtonClicked))
    }
    
    @objc func showPastOrders(){
        // show past orders
    }
    
}
