//
//  LabelWithPadding.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class LabelWithPadding: UILabel {
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 5
        let width = originalContentSize.width + 5
        return CGSize(width: width, height: height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
