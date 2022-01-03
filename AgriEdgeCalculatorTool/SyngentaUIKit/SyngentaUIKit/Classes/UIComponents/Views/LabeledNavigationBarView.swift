//
//  LabeledNavigationBarView.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 11/4/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class LabeledNavigationBarView: UIView, NibLoadable {

    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    // MARK: Public Configure
    
    public func configure(titleLabelText: String, subtitleLabelText: String?) {
        titleLabel.textColor = SemanticCustomColor.primaryInk.uiColor
        subtitleLabel.textColor = SemanticCustomColor.secondaryInk.uiColor
        titleLabel.text = titleLabelText
        
        if let subtitleLabelText = subtitleLabelText {
            subtitleLabel.text = subtitleLabelText
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
    
    // MARK: Public Properties
    
    public var titleLabelText: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    public var subtitleLabelText: String? {
        get {
            return subtitleLabel.text
        }
        set {
            if let newValue = newValue {
                subtitleLabel.text = newValue
                subtitleLabel.isHidden = false
            } else {
                subtitleLabel.isHidden = true
            }
        }
    }

}
