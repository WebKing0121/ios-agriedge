//
//  BorderedTextField.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/13/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class BorderedTextField: UITextField {

    override public func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont.systemFont(ofSize: 15)
        layer.cornerRadius = 4
        layer.borderWidth = 2
        layer.borderColor = UIColor.neutral700.cgColor
        backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
    }

}
