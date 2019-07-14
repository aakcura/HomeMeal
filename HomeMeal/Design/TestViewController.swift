//
//  ViewController.swift
//  HomeMeal
//
//  Created by Batuhan Abay on 2.07.2019.
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import Crashlytics

class TestViewController: UIViewController {

    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var lblSecond: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lbl.font = FontAwesomeFonts.solid
        
        //lblSecond.font = FontAwesomeFonts.regular
        let attributesIcon = [
            NSAttributedString.Key.font: FontAwesomeFonts.regular.withSize(32.0),
            NSAttributedString.Key.foregroundColor:UIColor.blue
        ]
        
        let attributesNormal = [
            NSAttributedString.Key.foregroundColor:UIColor.black
        ]
        
        let alertMessageText = NSMutableAttributedString(string: AppIcons.faAddressCard, attributes: attributesIcon)
        alertMessageText.append(NSAttributedString(string: " address", attributes: attributesNormal))
        
        lblSecond.attributedText = alertMessageText
        
        lblSecond.isUserInteractionEnabled = true
        lblSecond.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(labelTapped)))
        
    }
    
    @objc func labelTapped(){
        print("label tapped")
        Crashlytics.sharedInstance().crash()
    }

    @IBAction func sendCrashButtonClicked(_ sender: Any) {
        print("sendCrashButtonClicked")
        Crashlytics.sharedInstance().crash()
        
    }
    
}

