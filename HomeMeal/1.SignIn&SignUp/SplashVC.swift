//
//  SplashScreenVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class SplashVC: UIViewController {
    
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var lblInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.checkUserAccountStatusAndSession()
    }
    
    @objc private func checkUserAccountStatusAndSession(){
        self.activityIndicatorView.startAnimating()
        if let sessionID = UserDefaults.standard.string(forKey: UserDefaultsKeys.userSessionId), let currentUserId = AppConstants.currentUserId {
            if NetworkManager.isConnectedNetwork(){
                let dbRef = Database.database().reference()
                dbRef.child("users").child(currentUserId).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String:AnyObject], let accountInfoDictionary = dictionary["accountInfo"] as? [String:AnyObject]{
                        let accountInfo = AccountInfo(dictionary: accountInfoDictionary)
                        if let accountStatus = accountInfo.status, let accountType = accountInfo.accountType {
                            if accountStatus == .enabled {
                                dbRef.child("sessions/\(currentUserId)/\(sessionID)").observeSingleEvent(of: .value) { (snapshot) in
                                    if let dictionary = snapshot.value as? [String: AnyObject], let sessionStatus = dictionary["sessionStatus"] as? Int {
                                        if sessionStatus == SessionStatus.active.rawValue {
                                            self.showMainVC(for: accountType)
                                        }else{
                                            self.showLoginVC()
                                        }
                                    }else{
                                        self.showLoginVC()
                                    }
                                }
                            }else{
                                self.showLoginVC()
                            }
                        }
                    }else{
                        self.showLoginVC()
                    }
                })
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicatorView.stopAnimating()
                    self?.lblInfo.text = "NoInternetConnectionErrorMessage".getLocalizedString()
                    self?.lblInfo.isUserInteractionEnabled = true
                    self?.lblInfo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self?.checkUserAccountStatusAndSession)))
                }
            }
        }else{
            self.showLoginVC()
        }
    }
    
    private func showLoginVC(){
        if activityIndicatorView.isAnimating{
            DispatchQueue.main.async { self.activityIndicatorView.stopAnimating() }
        }
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userSessionId)
        AppDelegate.shared.rootViewController.switchToLogout()
    }
    
    private func showMainVC(for accountType: AccountType){
        if activityIndicatorView.isAnimating{
            DispatchQueue.main.async { self.activityIndicatorView.stopAnimating() }
        }
        AppDelegate.shared.rootViewController.switchToMainScreen(by: accountType)
    }
}

