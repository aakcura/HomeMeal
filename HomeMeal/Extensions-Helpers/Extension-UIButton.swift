//
//  Extension-UIButton.swift
//  HomeMeal
//
//  Copyright © 2019 Arin Akcura. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func addPulseEffect(){
        let pulseAnimation = CASpringAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.6
        pulseAnimation.fromValue = 0.95
        pulseAnimation.toValue = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = 2
        pulseAnimation.initialVelocity = 0.5
        pulseAnimation.damping = 1.0
        
        layer.add(pulseAnimation, forKey: nil)
    }
    
    func addFlashEffect(){
        let flashAnimation = CABasicAnimation(keyPath: "opacity")
        flashAnimation.duration = 0.5
        flashAnimation.fromValue = 1.0
        flashAnimation.toValue = 0.1
        flashAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flashAnimation.autoreverses = true
        flashAnimation.repeatCount = 1
        
        layer.add(flashAnimation, forKey: nil)
    }
    
    func addShakeEffect(){
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.1
        shakeAnimation.autoreverses = true
        shakeAnimation.repeatCount = 2
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let fromPoint = CGPoint(x: (center.x - 5), y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        let toPoint = CGPoint(x: (center.x + 5), y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shakeAnimation.fromValue = fromValue
        shakeAnimation.toValue = toValue
        
        layer.add(shakeAnimation, forKey: nil)
    }
    
}
