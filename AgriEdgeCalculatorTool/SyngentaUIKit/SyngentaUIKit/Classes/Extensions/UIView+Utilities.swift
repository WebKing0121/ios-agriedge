//
//  UIView+Utilities.swift
//  Pods-SyngentaUIKit
//
//  Created by Matt Jankowiak on 10/10/19.
//

import UIKit

public extension UIView {
        
    @IBInspectable var cornerRadius: Double {
        get {
            return Double(layer.cornerRadius)
        }
        set {
            layer.cornerRadius = CGFloat(newValue)
        }
    }
    
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        layer.maskedCorners = corners
        layer.cornerRadius = radius
    }

}
