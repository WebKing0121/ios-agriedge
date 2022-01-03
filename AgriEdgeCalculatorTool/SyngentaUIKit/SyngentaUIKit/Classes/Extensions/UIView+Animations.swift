//
//  UIView+Animations.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/12/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

extension UIView {
    
    public func fadeIn() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1.0
            })
        }
    }
    
    public func fadeOut() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0.0
            })
        }
    }

}
