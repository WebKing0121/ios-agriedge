//
//  LabeledToggleTableViewCell.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/9/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class LabeledToggleTableViewCell: UITableViewCell, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var toggleSwitch: UISwitch!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var titleLabelLeadingConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    
    public weak var delegate: LabeledToggleTableViewCellDelegate?
    
    public var titleLabelText: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    public var titleLabelFont: UIFont {
        get {
            return titleLabel.font
        }
        set {
            titleLabel.font = newValue
        }
    }
    
    public var titleLabelColor: UIColor {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
        }
    }
    
    public var titleLabelLeadingConstraintConstant: CGFloat {
        get {
            return titleLabelLeadingConstraint.constant
        }
        set {
            titleLabelLeadingConstraint.constant = newValue
        }
    }
    
    public var isCellSeparatorHidden: Bool {
        get {
            return separatorView.isHidden
        }
        set {
            separatorView.isHidden = newValue
        }
    }
    
    public var isToggleOn: Bool {
        get {
            return toggleSwitch.isOn
        }
        set {
            toggleSwitch.isOn = newValue
        }
    }
    
    // MARK: Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        toggleSwitch.onTintColor = .teal500
        toggleSwitch.tintColor = .teal500
    }

    // MARK: Actions
    
    @IBAction private func toggle(_ sender: UISwitch) {
        delegate?.didToggleSwitch(self, sender: sender)
    }
    
}

// MARK: - LabeledToggleTableViewCellDelegate

public protocol LabeledToggleTableViewCellDelegate: AnyObject {
    func didToggleSwitch(_ labeledToggleTableViewCell: LabeledToggleTableViewCell, sender: UISwitch)
}
