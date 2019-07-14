//
//  ChooseEmailActionSheetPresenter.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

protocol ChooseEmailActionSheetPresenter {
    var chooseEmailActionSheet: UIAlertController? { get }
    func setupChooseEmailActionSheet(withTitle title: String?) -> UIAlertController
}
extension ChooseEmailActionSheetPresenter {
    func setupChooseEmailActionSheet(withTitle title:String? = "Choose email") -> UIAlertController {
        let emailActionSheet = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        emailActionSheet.addAction(UIAlertAction(title: "Close".getLocalizedString(), style: .cancel, handler: nil))
        return emailActionSheet
    }
}
