//
//  Protocols.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

protocol PopupVCDisplayProtocol {
}
extension PopupVCDisplayProtocol {
    func addPopupVC(showThis popupVC:UIViewController, on vc:UIViewController, withTag viewTag:Int){
        vc.addChild(popupVC)
        popupVC.didMove(toParent: vc)
        popupVC.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(popupVC.view)
        popupVC.view.tag = viewTag
        popupVC.view.fillSuperView()
    }
    
    func removePopupVC(from vc:UIViewController, withTag viewTag:Int){
        if let viewToRemove = vc.view.viewWithTag(viewTag){
            viewToRemove.removeFromSuperview()
        }
    }
}
