//
//  StyledButtonTableSectionHeader.swift
//  Pods-SyngentaUIKit
//
//  Created by Matt Jankowiak on 10/20/19.
//

import UIKit

public class StyledButtonTableSectionHeader: UITableViewHeaderFooterView, NibLoadable {

    // MARK: Outlets
    
    @IBOutlet private weak var styledButton: StyledButton!
    @IBOutlet private weak var background: UIView!
    
    // MARK: Public Properties
    
    public weak var delegate: StyledButtonTableSectionHeaderDelegate?
    
    public var buttonTitleLabelText: String? {
        get {
            return styledButton.titleLabel?.text
        }
        set {
            styledButton.setTitle(newValue, for: .normal)
        }
    }
    
    public var buttonType: (style: ButtonStyle, color: ButtonColor) = (.primary, .teal) {
        didSet {
            styledButton.configure(buttonStyle: buttonType.style, buttonColor: buttonType.color)
        }
    }
    
    // MARK: View Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        background.backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
    }
    
    public override func draw(_ rect: CGRect) {
        drawShadow(on: .top)
    }
    
    // MARK: Actions
    
    @IBAction private func didTapButton(_ sender: StyledButton) {
        delegate?.didTapStyledButton(self, sender: sender)
    }
    
}

public protocol StyledButtonTableSectionHeaderDelegate: AnyObject {
    func didTapStyledButton(_ styledButtonTableSectionHeader: StyledButtonTableSectionHeader, sender: StyledButton)
}
