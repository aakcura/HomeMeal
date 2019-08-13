//
//  InformationVC.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class InformationVC: UIViewController {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var lblInformation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnClose.setCornerRadius(radiusValue: 5.0, makeRoundCorner: true)
        btnClose.setTitle("X", for: .normal)
    }

    func configureInformationVC(message:String, shouldAnimate:Bool, showCloseButton:Bool){
        lblInformation.text = message
        if shouldAnimate {
            activityIndicatorView.startAnimating()
        }else{
            activityIndicatorView.stopAnimating()
        }
        
        if showCloseButton {
            btnClose.isHidden = false
        }else{
            btnClose.isHidden = true
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
