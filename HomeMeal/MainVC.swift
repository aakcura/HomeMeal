//
//  MainVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColors.appWhiteColor
        title = "Main Screen"
        let signOutButton = UIBarButtonItem.init(image: AppIcons.signOutIcon, style: .plain, target: self, action: #selector(signOut))
        self.navigationItem.rightBarButtonItems = [signOutButton]
    }
    
    func showActivityScreen(){
        let activityScreen = ActivityVC()
        self.navigationController?.pushViewController(activityScreen, animated: true)
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
                AlertService.showAlert(in: self, message: "NoInternetConnectionErrorMessage".getLocalizedString(), title: "NoInternetConnectionError".getLocalizedString(), style: .alert)
            }
        }
    }

}
