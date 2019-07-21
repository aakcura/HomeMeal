//
//  ViewController.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit
import UserNotifications
import Crashlytics

class TestViewController: UIViewController {

    @IBOutlet weak var firstLbl: UILabel!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var lblSecond: UILabel!
    
    var currentProfile = AccountTypeList.customer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        lbl.setCustomFont(fontType: .solidFontAwesome, textColor: .red)
        
        //lblSecond.font = FontAwesomeFonts.regular
        
        let alertMessageText = NSMutableAttributedString(string: AppIcons.faAddressCard)
        alertMessageText.addCustomAttributes(fontType: .regularFontAwesome, fontSize: 24.0, color: .black)
        let x = NSMutableAttributedString(string: "User Address:")
        x.addCustomAttributes(fontType: .boldSystem,fontSize: 18.0, color: .black, range: nil)
        alertMessageText.append(x)
        lblSecond.attributedText = alertMessageText
    }
    
    @IBAction func switchProfileClicked(_ sender: Any) {
        currentProfile = currentProfile == .customer ? .chef : .customer
        configureFor(profileType: currentProfile)
    }
    @IBAction func sendLocalNotificationClicked(_ sender: Any) {
        self.sendLocalNotification(lbMessageId: "message IDentifier", notificationContentDictionary: ["body":"You have message waiting to be opened near you. Check and join the fun ;)".getLocalizedString(), "sound":UNNotificationSound.default] as [String:Any])
    }
    
    private func sendLocalNotification(lbMessageId: String, notificationContentDictionary: [String:Any]){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized{
                let content = UNMutableNotificationContent()
                //content.title = notificationContentDictionary["title"] as! String
                content.body = notificationContentDictionary["body"] as! String
                content.sound = notificationContentDictionary["sound"] as? UNNotificationSound
                let request = UNNotificationRequest(identifier: lbMessageId, content: content, trigger: nil)
                notificationCenter.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
            }
        }
    }
    
    
    
    func configureFor(profileType: AccountTypeList) {
        title = profileType.rawValue
        ShortcutParser.shared.registerShortcuts(for: profileType)
    }
    
}

