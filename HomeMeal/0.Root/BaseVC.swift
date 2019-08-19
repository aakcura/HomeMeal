//
//  BaseVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

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

// SHARE APP SECTION
extension BaseVC {
    func getAppShareMessage(completion: @escaping (String?) -> Void){
        if NetworkManager.isConnectedNetwork(){
            Database.database().reference().child("appShareLinks").child("shareMessages").observeSingleEvent(of: .value) { (snapshot) in
                if let value = snapshot.value as? [String:String] {
                    var message:String
                    if self.isUserPreferredLanguageTurkish(){
                        message = value["tr"]!
                    }else{
                        message = value["en"]!
                    }
                    UserDefaults.standard.set(message, forKey:  UserDefaultsKeys.appShareMessage)
                    completion(message)
                }else{
                    completion(nil)
                }
            }
        }else{
            completion(self.getCachedAppShareMessage())
        }
    }
    
    private func getCachedAppShareMessage() -> String?{
        if let appShareMessage = UserDefaults.standard.string(forKey: UserDefaultsKeys.appShareMessage) {
            return appShareMessage
        }else{
            return nil
        }
    }
    
    ///Controls user preferred language. If the preferred language is turkish it returns true.
    private func isUserPreferredLanguageTurkish() -> Bool{
        if let userPreferredLanguageCode = Locale.current.languageCode{
            if userPreferredLanguageCode.elementsEqual("tr") || userPreferredLanguageCode.elementsEqual("tur"){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
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
