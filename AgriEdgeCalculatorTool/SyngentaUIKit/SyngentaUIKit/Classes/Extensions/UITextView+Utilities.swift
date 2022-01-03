//
//  UITextView+Utilities.swift
//  SyngentaUIKit
//
//  Created by Garima on 23/10/19.
//

import UIKit

extension UITextView {
    
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
