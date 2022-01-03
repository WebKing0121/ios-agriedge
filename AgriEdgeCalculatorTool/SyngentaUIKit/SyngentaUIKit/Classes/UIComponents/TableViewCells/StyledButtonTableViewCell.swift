//
//  StyledButtonTableViewCell.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/9/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class StyledButtonTableViewCell: UITableViewCell, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var button: StyledButton!
    
    // MARK: Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    // MARK: Properties
    
    public weak var delegate: StyledButtonTableViewCellDelegate?
    
    public var buttonTitleLabelText: String? {
        get {
            return button.titleLabel?.text
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }
    
    public var buttonType: (style: ButtonStyle, color: ButtonColor) = (.primary, .teal) {
        didSet {
            button.configure(buttonStyle: buttonType.style, buttonColor: buttonType.color)
        }
    }
    
    // MARK: Actions
    
    @IBAction private func buttonTap(_ sender: StyledButton) {
        delegate?.didTapButton(self, sender: sender)
    }
    
}

public protocol StyledButtonTableViewCellDelegate: AnyObject {
    func didTapButton(_ styledButtonTableViewCell: StyledButtonTableViewCell, sender: StyledButton)
}
