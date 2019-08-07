//
//  Extension-String.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func getLocalizedString(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "\(self)", comment: "")
    }
}

extension NSMutableAttributedString{
    func addCustomAttributes(fontType: AppFontTypes = AppFontTypes.system, fontSize: CGFloat = UIFont.labelFontSize, color: UIColor = .black, range: NSRange? = nil, underlineStyle: NSUnderlineStyle? = nil){
        var customfont: UIFont
        switch fontType {
        case .regularFontAwesome:
            customfont = FontAwesomeFonts.regular.withSize(fontSize)
            break
        case .solidFontAwesome:
            customfont = FontAwesomeFonts.solid.withSize(fontSize)
            break
        case .brandsFontAwesome:
            customfont = FontAwesomeFonts.brands.withSize(fontSize)
            break
        case .system:
            customfont = UIFont.systemFont(ofSize: fontSize)
            break
        case .boldSystem:
            customfont = UIFont.boldSystemFont(ofSize: fontSize)
            break
        case .italicSystem:
            customfont = UIFont.italicSystemFont(ofSize: fontSize)
            break
        }
        
        let range = range ?? NSRange(location: 0, length: self.length)
        if let underlineStyle = underlineStyle {
            let attributes = [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : customfont, NSAttributedString.Key.underlineStyle: underlineStyle.rawValue] as [NSAttributedString.Key : Any]
            self.addAttributes(attributes, range: range)
        }else{
            let attributes = [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : customfont] as [NSAttributedString.Key : Any]
            self.addAttributes(attributes, range: range)
        }
    }
    
    func underline(with style: NSUnderlineStyle = NSUnderlineStyle.single, range: NSRange? = nil){
        let range = range ?? NSRange(location: 0, length: self.length)
        let attributes = [NSAttributedString.Key.underlineStyle: style.rawValue]
        self.addAttributes(attributes, range: range)
    }
    
}

