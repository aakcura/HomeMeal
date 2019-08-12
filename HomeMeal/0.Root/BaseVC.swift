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
    
    let activityIndicator : UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.color = AppColors.appOrangeColor
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension BaseVC: ActivityIndicatorDisplayProtocol{
    
    func addActivityIndicatorToView(){
        if !view.subviews.contains(activityIndicator) {
            view.addSubview(activityIndicator)
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
    }
    
    func showActivityIndicatorView(isUserInteractionEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.view.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }
    
    func hideActivityIndicatorView(isUserInteractionEnabled: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.view.isUserInteractionEnabled = isUserInteractionEnabled
        }
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
