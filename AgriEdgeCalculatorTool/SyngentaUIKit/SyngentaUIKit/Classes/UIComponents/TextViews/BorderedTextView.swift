//
//  BorderedTextView.swift
//  SyngentaUIKit
//
//  Created by Garima on 22/10/19.
//

import UIKit

class BorderedTextView: UITextView {

    override public func awakeFromNib() {
        super.awakeFromNib()
        font = UIFont.systemFont(ofSize: 15)
        layer.cornerRadius = 4
        layer.borderWidth = 2
        layer.borderColor = UIColor.neutral700.cgColor
        contentInset = .zero
        textContainer.lineFragmentPadding = 15
    }

}
