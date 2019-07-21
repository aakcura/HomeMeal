//
//  Extension-UILabel.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

extension UILabel{
   
    func setCustomFont(fontType:AppFontTypes = AppFontTypes.regularFontAwesome, fontSize: CGFloat = UIFont.labelFontSize, textColor: UIColor = .black){
        switch fontType {
        case .regularFontAwesome:
            self.font = FontAwesomeFonts.regular.withSize(fontSize)
            break
        case .solidFontAwesome:
            self.font = FontAwesomeFonts.solid.withSize(fontSize)
            break
        case .brandsFontAwesome:
            self.font = FontAwesomeFonts.brands.withSize(fontSize)
            break
        default:
            break
        }
        self.textColor = textColor
    }

}
