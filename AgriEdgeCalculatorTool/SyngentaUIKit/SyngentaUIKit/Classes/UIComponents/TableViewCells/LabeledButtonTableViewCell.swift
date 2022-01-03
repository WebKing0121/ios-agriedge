//
//  LabeledButtonTableViewCell.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/9/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class LabeledButtonTableViewCell: UITableViewCell, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    // MARK: Properties
    
    public weak var delegate: LabeledButtonTableViewCellDelegate?
    
    public var titleLabelText: String? {
        get {
            return titleLabel?.text
        }
        set {
            titleLabel?.text = newValue
        }
    }
    
    public var buttonLabelText: String? {
        get {
            return button?.titleLabel?.text
        }
        set {
            button?.setTitle(newValue, for: .normal)
        }
    }
    
    // MARK: Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        button.setTitleColor(.teal500, for: .normal)
    }
    
    // MARK: Actions
    
    @IBAction private func buttonTap(_ sender: UIButton) {
        delegate?.didTapButton(self, sender: sender)
    }
    
}

// MARK: - LabeledButtonTableViewCellDelegate

public protocol LabeledButtonTableViewCellDelegate: AnyObject {
    func didTapButton(_ labeledButtonTableViewCell: LabeledButtonTableViewCell, sender: UIButton)
}
