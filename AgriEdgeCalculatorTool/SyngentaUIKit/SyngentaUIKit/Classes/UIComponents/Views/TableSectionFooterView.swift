//
//  TableSectionFooterView.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/13/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class TableSectionFooterView: UIView, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var shadowView: UIView!
    
    // MARK: View Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
    }
    
    public override func draw(_ rect: CGRect) {
        shadowView.drawShadow(on: .bottom)
    }

}
