//
//  StyledButton.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 9/18/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class StyledButton: UIButton, NibLoadable {
        
    // MARK: Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureDefaults()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureDefaults()
    }
    
    // MARK: Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        configureDefaults()
    }
    
    // MARK: Override Properties
    
    override public var isEnabled: Bool {
        didSet {
            styleButtonControlState(isEnabled: isEnabled)
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            styleButtonHighlightedState(isHighlighted: isHighlighted)
        }
    }
    
    // MARK: Private Properties
    
    private var buttonStyle: ButtonStyle = .primary
    private var buttonColor: ButtonColor = .teal
    
    // MARK: Public Configure
    
    public func configure(buttonStyle: ButtonStyle, buttonColor: ButtonColor) {
        self.buttonStyle = buttonStyle
        self.buttonColor = buttonColor
        styleButtonControlState(isEnabled: true)
    }
    
    // MARK: Private Helpers
    
    private func configureDefaults() {
        layer.cornerRadius = 4
        titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
    }
    
    private func styleButtonControlState(isEnabled: Bool) {
        if isEnabled {
            switch buttonStyle {
            case .primary:
                layer.borderWidth = 0
                setTitleColor(.solidWhite, for: .normal)
                switch buttonColor {
                case .teal:
                    backgroundColor = .teal500
                case .red:
                    backgroundColor = .red500
                case .black:
                    backgroundColor = SemanticCustomColor.primaryInk.uiColor
                }
            case .secondary:
                layer.borderWidth = 0
                switch buttonColor {
                case .teal:
                    setTitleColor(.teal500, for: .normal)
                    backgroundColor = .teal100
                case .red:
                    setTitleColor(.red500, for: .normal)
                    backgroundColor = .red100
                case .black:
                    setTitleColor(SemanticCustomColor.primaryInk.uiColor, for: .normal)
                    backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
                }
            case .tertiary:
                layer.borderWidth = 1
                backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
                switch buttonColor {
                case .teal:
                    setTitleColor(.teal500, for: .normal)
                    layer.borderColor = UIColor.teal500.cgColor
                case .red:
                    setTitleColor(.red500, for: .normal)
                    layer.borderColor = UIColor.red500.cgColor
                case .black:
                    setTitleColor(SemanticCustomColor.primaryInk.uiColor, for: .normal)
                    layer.borderColor = SemanticCustomColor.primaryInk.cgColor
                }
            case .text:
                layer.borderWidth = 0
                backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
                switch buttonColor {
                case .teal:
                    setTitleColor(.teal500, for: .normal)
                case .red:
                    setTitleColor(.red500, for: .normal)
                case .black:
                    setTitleColor(.black, for: .normal)
                }
            }
        } else {
            layer.borderWidth = 0
            backgroundColor = .neutral500
            setTitleColor(.ink700, for: .disabled)
        }
    }
    
    private func styleButtonHighlightedState(isHighlighted: Bool) {
        switch buttonStyle {
        case .primary:
            switch buttonColor {
            case .teal:
                backgroundColor = isHighlighted ? .teal700 : .teal500
            case .red:
                backgroundColor = isHighlighted ? .red700 : .red500
            case .black:
                backgroundColor = SemanticCustomColor.primaryInk.uiColor
            }
        case .secondary:
            switch buttonColor {
            case .teal:
                backgroundColor = isHighlighted ? .teal300 : .teal100
            case .red:
                backgroundColor = isHighlighted ? .red300 : .red100
            case .black:
                backgroundColor = SemanticCustomColor.primaryInk.uiColor
            }
        case .tertiary, .text:
            backgroundColor = isHighlighted ? .neutral500 : SemanticCustomColor.tableSectionHeaderBackground.uiColor
        }
    }
    
}

public enum ButtonColor {
    case teal
    case red
    case black
}

public enum ButtonStyle {
    case primary
    case secondary
    case tertiary
    case text
}
