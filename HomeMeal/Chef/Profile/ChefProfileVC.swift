//
//  ChefProfileVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class ChefProfileVC: UIViewController, ChooseEmailActionSheetPresenter {
    
    func showActivityScreen(){
        let activityScreen = ActivityVC()
        self.navigationController?.pushViewController(activityScreen, animated: true)
    }
    
    var userId: String?{
        didSet{
            if let userId = self.userId {
                
            }
        }
    }
    
    var user: Chef? {
        didSet{
            // configureUI
            print(user)
            print(user?.email,user?.name)
        }
    }
    
    var chooseEmailActionSheet: UIAlertController? {
        return setupChooseEmailActionSheet(withTitle: "Contact Us".getLocalizedString())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIProperties()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let currentUser = AppDelegate.shared.currentUserAsChef else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error".getLocalizedString(), message: "Profil bilgileriniz bulunamadı lütfen tekrar giriş yapınız".getLocalizedString(), preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close".getLocalizedString(), style: .destructive) { (action) in
                    self.signOut()
                }
                alert.addAction(closeAction)
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        self.user = currentUser
    }
    
    private func setupUIProperties(){
        self.view.backgroundColor = AppColors.appWhiteColor
        configureUIForCurrentUser()
    }
    
    private func configureUIForCurrentUser(){
        customizeNavBarForCurrentUser()
    }
    
    private func configureUIForAnyUser(){
        customizeNavBarForAnyUser()
    }
    
    private func customizeNavBarForAnyUser(){
        self.setNavBarTitle("Profile".getLocalizedString())
        let backBarButtton = UIBarButtonItem(image: AppIcons.arrowLeftIcon, style: .plain, target: self, action: #selector(self.closeVC))
        self.navigationItem.leftBarButtonItem = backBarButtton
    }
    
    private func customizeNavBarForCurrentUser(){
        self.setNavBarTitle("Profile".getLocalizedString())
        let settingsBarButtonItem = UIBarButtonItem(image: AppIcons.settingsIcon, style: .plain, target: self, action: #selector(settingsButtonClicked))
        self.navigationItem.rightBarButtonItem = settingsBarButtonItem
    }
    
    @objc func closeVC(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func settingsButtonClicked() {
        let alert = UIAlertController(title: "Settings".getLocalizedString(), message: nil, preferredStyle: .actionSheet)
        
        let contactUsViaMailAction = UIAlertAction(title: "Contact Us".getLocalizedString(), style: .default) { (action) in
            self.contactUsViaMail()
        }
        
        let goToProfileSettingsAction = UIAlertAction(title: "Go to Profile Settings".getLocalizedString(), style: .default) { (action) in
            self.goToProfileSettings()
        }
        
        let signOutAction = UIAlertAction(title: "Sign Out".getLocalizedString(), style: .destructive) { (action) in
            let alert = UIAlertController(title: nil, message: "Are you sure you want to sign out".getLocalizedString(), preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes".getLocalizedString(), style: .destructive) { (action) in
                self.signOut()
            }
            let noAction = UIAlertAction(title: "No".getLocalizedString(), style: .default, handler: nil)
            alert.addAction(noAction)
            alert.addAction(yesAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        let closeAction = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
        
        alert.addAction(goToProfileSettingsAction)
        alert.addAction(contactUsViaMailAction)
        alert.addAction(signOutAction)
        alert.addAction(closeAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func signOut(){
        // store the user session (example only, not for the production)
        if NetworkManager.isConnectedNetwork(){
            do {
                if let uid = AppConstants.currentUserId, let sessionId = UserDefaults.standard.string(forKey: UserDefaultsKeys.userSessionId), let accountType = AppDelegate.shared.currentUserAccountType{
                    let dbRef = Database.database().reference()
                    if accountType == .chef {
                        dbRef.child("chefs").child(uid).child("fcmToken").removeValue()
                    }else if accountType == .customer {
                        dbRef.child("customers").child(uid).child("fcmToken").removeValue()
                    }
                    let sessionsRef = dbRef.child("sessions").child(uid).child(sessionId)
                    let values = [ "endTime" : Date().timeIntervalSince1970, "sessionStatus": SessionStatus.passive.rawValue] as [String:AnyObject]
                    sessionsRef.updateChildValues(values) { (error, ref) in
                        if let error = error {
                            // TODO: Error handling
                            print(error.localizedDescription)
                            return
                        }
                    }
                }
                try Auth.auth().signOut()
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userSessionId)
                AppDelegate.shared.rootViewController.switchToLogout()
            } catch let signOutError as NSError {
                DispatchQueue.main.async { [weak self] in
                    AlertService.showAlert(in: self, message: "Error signing out: \(signOutError)", style: .alert)
                }
            }
        }else{
            DispatchQueue.main.async { [weak self] in
                AlertService.showNoInternetConnectionErrorAlert(in: self, style: .alert, blockUI: false)
            }
        }
    }
}

extension ChefProfileVC {
    private func getUserByUserId(_ userId:String){
        if NetworkManager.isConnectedNetwork(){
            Database.database().reference().child("chefs/\(userId)").observe(.value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let user = Chef(dictionary: dictionary)
                    self.user = user
                }
            }
        }else{
            DispatchQueue.main.async {
                AlertService.showNoInternetConnectionErrorAlert(in: self)
            }
        }
    }
    
    // NOT IN USE
    private func getUserByUserId(_ userId:String, completion: @escaping (Chef?) -> Void){
        if NetworkManager.isConnectedNetwork(){
            Database.database().reference().child("chefs/\(userId)").observe(.value) { (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let user = Chef(dictionary: dictionary)
                    completion(user)
                }else{
                    completion(nil)
                }
            }
        }else{
            DispatchQueue.main.async {
                AlertService.showNoInternetConnectionErrorAlert(in: self)
            }
        }
    }
}

// SETTINGS SECTION
extension ChefProfileVC {
    @objc func contactUsViaMail() {
        guard let emailActionSheet = chooseEmailActionSheet else{
            return
        }
        
        let developerMail = "aakcura2001@gmail.com"
        let mailsubject = "HomeMeal - Contact".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "HomeMeal"
        let deviceAndAppInfo = DeviceAndAppInfo.init()
        let mailBody = "\n\n\nHomeMeal v\(deviceAndAppInfo.applicationVersionNumber ?? "") - \(deviceAndAppInfo.deviceModel)\(deviceAndAppInfo.deviceOSName) \(deviceAndAppInfo.deviceOSVersionName)".addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
        
        let appleMailURL = "mailto:\(developerMail)?subject=\(mailsubject)&body=\(mailBody)"
        let gmailURL = "googlegmail://co?to=\(developerMail)&subject=\(mailsubject)&body=\(mailBody)"
        let outlookURL = "ms-outlook://compose?to=\(developerMail)&subject=\(mailsubject)&body=\(mailBody)"
        
        
        if let action = openAction(withURL: appleMailURL, andTitleActionTitle: "Through Mail".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: gmailURL, andTitleActionTitle: "Through Gmail".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: outlookURL, andTitleActionTitle: "Through Outlook".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: "WebSiteURL".getLocalizedString(), andTitleActionTitle: "Through Website".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        if let action = openAction(withURL: "Terms, and Data Policy URL".getLocalizedString(), andTitleActionTitle: "Show Terms and Data Policy".getLocalizedString()) {
            emailActionSheet.addAction(action)
        }
        
        present(emailActionSheet, animated: true, completion: nil)
    }
    
    private func openAction(withURL: String, andTitleActionTitle: String) -> UIAlertAction? {
        guard let url = URL(string: withURL), UIApplication.shared.canOpenURL(url) else {
            return nil
        }
        let action = UIAlertAction(title: andTitleActionTitle, style: .default) { (action) in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return action
    }
    
    private func goToProfileSettings(){
        guard let user = self.user else { return }
        let profileSettingsVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: "ChefProfileEditVC") as! ChefProfileEditVC
        profileSettingsVC.chef = user
        let profileSettingsNavigationController = UINavigationController(rootViewController: profileSettingsVC)
        self.present(profileSettingsNavigationController, animated: true, completion: nil)
    }
}
