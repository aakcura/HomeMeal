//
//  BaseVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {

    var searchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.searchBarStyle = .prominent
        return searchbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// SEARCH BAR IN NAVBAR SETTINGS
extension BaseVC{
    func addSearchButtonToNavBarRight(){
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(searchButtonClicked))]
    }
    
    @objc private func searchButtonClicked(){
        self.addSearchBarToNavBar()
    }
    
    private func addSearchBarToNavBar(){
        navigationItem.titleView = self.searchBar
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(closeSearchBarButtonClicked))]
        self.searchBar.becomeFirstResponder()
    }
    
    @objc func closeSearchBarButtonClicked(){
        self.searchBar.text = ""
        self.navigationItem.titleView = nil
        self.addSearchButtonToNavBarRight()
    }
}
