//
//  UIView+Shadows.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/13/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

extension UIView {
    
    public enum ShadowEdge {
        case top
        case bottom
        case all
    }
    
    public func drawShadow(on edge: ShadowEdge) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.neutral700.cgColor
        layer.shadowRadius = 2
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        
        var rectHeight: CGFloat
        var rectY: CGFloat
        
        switch edge {
        case .all:
            rectY = 0
            rectHeight = bounds.size.height
        case .top:
            rectY = 0
            rectHeight = 1
        case .bottom:
            rectY = bounds.size.height
            rectHeight = 1
        }
                
        let rect = CGRect(x: 0, y: rectY, width: bounds.size.width, height: rectHeight)
        layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
    
    public func removeShadow() {
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero
    }
    
}
