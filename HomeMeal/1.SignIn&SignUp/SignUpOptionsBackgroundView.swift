//
//  SignUpOptionsBackgroundView.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import UIKit

class SignUpOptionsBackgroundView: UIView {

    var path: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        drawMyShape()
        
        // Specify the fill color and apply it to the path.
        AppColors.appOrangeColor.setFill()
        path.fill()
    }
    
    func drawMyShape() {
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 15.0))
        path.addLine(to: CGPoint(x: (self.frame.size.width / 4) - 12.5, y: 15.0))
        path.addLine(to: CGPoint(x: (self.frame.size.width / 4) + 2.5, y: 0.0))
        path.addLine(to: CGPoint(x: (self.frame.size.width / 4) + 17.5, y: 15.0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 15.0))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
        path.close()
        
        /*
        let borderLayer = CAShapeLayer()
        borderLayer.path = path.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = AppColors.appLavaColor.cgColor
        borderLayer.lineWidth = 1
        self.layer.addSublayer(borderLayer)
        */
    }
}
