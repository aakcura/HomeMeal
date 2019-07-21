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
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.checkUserSession()
    }
    
    @objc private func checkUserSession(){
        self.activityIndicatorView.startAnimating()
        if let sessionID = UserDefaults.standard.string(forKey: UserDefaultsKeys.userSessionId), let currentUserId = AppConstants.currentUserId {
            if NetworkManager.isConnectedNetwork(){
                let dbRef = Database.database().reference().child("sessions/\(currentUserId)/\(sessionID)")
                dbRef.observeSingleEvent(of: .value) { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        if let status = dictionary["status"] as? Int{
                            if status == SessionStatus.active.rawValue {
                                self.showMainVC()
                            }else{
                                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userSessionId)
                                self.showLoginVC()
                            }
                        }else{
                            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userSessionId)
                            self.showLoginVC()
                        }
                    }else{
                        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userSessionId)
                        self.showLoginVC()
                    }
                }
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicatorView.stopAnimating()
                    self?.infoLabel.text = "NoInternetConnectionErrorMessage".getLocalizedString()
                    self?.infoLabel.isUserInteractionEnabled = true
                    self?.infoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self?.checkUserSession)))
                }
            }
        }else{
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userSessionId)
            self.showLoginVC()
        }
    }
    
    private func showLoginVC(){
        if activityIndicatorView.isAnimating{
            self.activityIndicatorView.stopAnimating()
        }
        AppDelegate.shared.rootViewController.switchToLogout()
    }
    
    private func showMainVC(){
        if activityIndicatorView.isAnimating{
            self.activityIndicatorView.stopAnimating()
        }
        AppDelegate.shared.rootViewController.switchToMainScreen()
    }
}

