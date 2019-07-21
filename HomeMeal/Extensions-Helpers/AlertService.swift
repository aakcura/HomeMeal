//
//  AlertService.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

class AlertService{
   
    static func showAlert(in vc:UIViewController?, message: String, title: String = "", style: UIAlertController.Style = .alert) {
        guard let vc = vc else {
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let closeButton = UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil)
        alert.addAction(closeButton)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showAlert(in vc:UIViewController?, message: String, title: String = "", buttonTitle: String, style: UIAlertController.Style, dismissVCWhenButtonClicked: Bool, isVCInNavigationStack: Bool) {
        guard let vc = vc else {
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let button =  UIAlertAction(title: buttonTitle, style: .cancel) { (action) in
            if dismissVCWhenButtonClicked {
                if isVCInNavigationStack {
                    vc.navigationController?.popViewController(animated: true)
                }else{
                    vc.dismiss(animated: true, completion: nil)
                }
                
            }
        }
        alert.addAction(button)
        vc.present(alert, animated: true, completion: nil)
    }
    
    
}
