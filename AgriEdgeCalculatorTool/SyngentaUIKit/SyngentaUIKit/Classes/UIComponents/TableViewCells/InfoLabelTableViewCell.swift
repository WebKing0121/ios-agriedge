//
//  InfoLabelTableViewCell.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/13/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class InfoLabelTableViewCell: UITableViewCell, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var infoLabel: UILabel!
    
    // MARK: View Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
    }
    
    // MARK: Properties
    
    public var infoLabelText: String? {
        get {
            return infoLabel.text
        }
        set {
            infoLabel.text = newValue
        }
    }
    
    public var labelAlignment: NSTextAlignment {
        get {
            return infoLabel.textAlignment
        }
        set {
            infoLabel.textAlignment = newValue
        }
    }
    
}
