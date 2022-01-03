//
//  LabeledTableViewCell.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/16/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class LabeledTableViewCell: UITableViewCell, NibLoadable {

    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var accessoryLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    // MARK: View Life Cycle
    
    public override func prepareForReuse() {
        separatorView.isHidden = false
    }
    
    // MARK: Configure
    
    public func configure(titleLabelText: String? = nil, subtitleLabelText: String? = nil, accessoryLabelText: String? = nil, isSeparatorHidden: Bool = false) {
        
        if let subtitleLabelText = subtitleLabelText {
            subtitleLabel.text = subtitleLabelText
        } else {
            isSubtitleLabelHidden = true
        }
        
        titleLabel.text = titleLabelText
        accessoryLabel.text = accessoryLabelText
        isCellSeparatorHidden = isSeparatorHidden
    }
    
    // MARK: Properties
    
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
            } else {
                isSubtitleLabelHidden = true
            }
        }
    }
    
    public var accessoryLabelText: String? {
        get {
            return accessoryLabel.text
        }
        set {
            accessoryLabel.text = newValue
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
    
    public var subtitleLabelFont: UIFont {
        get {
            return subtitleLabel.font
        }
        set {
            subtitleLabel.font = newValue
        }
    }
    
    public var accessoryLabelFont: UIFont {
        get {
            return accessoryLabel.font
        }
        set {
            accessoryLabel.font = newValue
        }
    }
    
    public var titleLabelColor: UIColor? {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
        }
    }
    
    public var subtitleLabelColor: UIColor? {
        get {
            return subtitleLabel.textColor
        }
        set {
            subtitleLabel.textColor = newValue
        }
    }
    
    public var accessoryLabelColor: UIColor? {
        get {
            return accessoryLabel.textColor
        }
        set {
            accessoryLabel.textColor = newValue
        }
    }
    
    public var titleLabelAttributedText: NSAttributedString? {
        get {
            return titleLabel.attributedText
        }
        set {
            titleLabel.attributedText = newValue
        }
    }

    public var subtitleLabelAttributedText: NSAttributedString? {
        get {
            return subtitleLabel.attributedText
        }
        set {
            subtitleLabel.attributedText = newValue
        }
    }

    public var accessoryLabelAttributedText: NSAttributedString? {
        get {
            return accessoryLabel.attributedText
        }
        set {
            accessoryLabel.attributedText = newValue
        }
    }
    
    public var isAccessoryLabelHidden: Bool {
        get {
            return accessoryLabel.isHidden
        }
        set {
            accessoryLabel.isHidden = newValue
        }
    }

    public var isSubtitleLabelHidden: Bool {
        get {
            return subtitleLabel.isHidden
        }
        set {
            subtitleLabel.isHidden = newValue
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
    
    public var accessoryLabelBackgroundColor: UIColor? {
        get {
            return accessoryLabel.backgroundColor
        }
        set {
            accessoryLabel.backgroundColor = newValue
        }
    }
    
}
