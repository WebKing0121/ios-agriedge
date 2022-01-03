//
//  UITextField+Utilities.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/9/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

extension UITextField {
    
    public var isActive: Bool {
        get {
            return self.isFirstResponder
        }
        set {
            if newValue {
                layer.borderColor = UIColor.teal500.cgColor
                backgroundColor = SemanticCustomColor.tableBackground.uiColor
            } else {
                layer.borderColor = UIColor.neutral700.cgColor
                backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
            }
        }
    }
    
}
