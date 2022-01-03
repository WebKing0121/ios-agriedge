//
//  LabeledTextFieldTableViewCell.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/13/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class LabeledTextFieldTableViewCell: UITableViewCell, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: BorderedTextField!
    @IBOutlet private weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorView: UIView!
    
    // MARK: Properties
    
    public weak var delegate: LabeledTextFieldTableViewCellDelegate?
    
    public var titleLabelText: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
            if newValue == nil {
                titleLabel.isHidden = true
                stackViewTopConstraint?.constant = 8
                stackViewBottomConstraint?.constant = 8
            }
        }
    }
    
    public var textFieldText: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    public var textFieldPlaceholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }
    
    public var textFieldContentType: UITextContentType {
        get {
            return textField.textContentType
        }
        set {
            textField.textContentType = newValue
        }
    }
    
    public var shouldShowArrowAccessoryView: Bool = false {
        didSet {
            if shouldShowArrowAccessoryView {
                let bundle = Bundle(for: LabeledTextFieldTableViewCell.self)
                let rightArrowImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
                rightArrowImageView.image = UIImage(named: "smallRightArrow", in: bundle, compatibleWith: nil)
                let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 24))
                rightView.addSubview(rightArrowImageView)

                textField.rightViewMode = .always
                textField.rightView = rightView
            } else {
                textField.rightView = nil
            }
        }
    }
    
    public var shouldShowSearchIconLeftView: Bool = false {
        didSet {
            if shouldShowSearchIconLeftView {
                let bundle = Bundle(for: LabeledTextFieldTableViewCell.self)
                let leftSearchIconImageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 24, height: 24))
                leftSearchIconImageView.image = UIImage(named: "searchIcon", in: bundle, compatibleWith: nil)
                leftSearchIconImageView.tintColor = .ink700
                let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
                leftView.addSubview(leftSearchIconImageView)
                
                textField.leftViewMode = .always
                textField.leftView = leftView
            } else {
                textField.leftView = nil
            }
        }
    }
        
    public var clearButtonMode: UITextField.ViewMode {
        get {
            return textField.clearButtonMode
        }
        set {
            textField.clearButtonMode = newValue
        }
    }
    
    public var textFieldKeyboardType: UIKeyboardType {
        get {
            return textField.keyboardType
        }
        set {
            textField.keyboardType = newValue
            switch newValue {
            case .emailAddress:
                textField.autocapitalizationType = .none
            default:
                textField.autocapitalizationType = .words
            }
        }
    }
    
    public var shouldTextFieldBecomeFirstResponder: Bool = false {
        didSet {
            if shouldTextFieldBecomeFirstResponder {
                textField.becomeFirstResponder()
            } else {
                textField.endEditing(true)
                textField.resignFirstResponder()
            }
        }
    }
    
    public var leftAccessoryView: UIView? {
        get {
            return textField.leftView
        }
        set {
            textField.leftViewMode = .always
            textField.leftView = newValue
        }
    }
    
    public var isTextFieldEnabled: Bool {
        get {
            return textField.isEnabled
        }
        set {
            textField.isEnabled = newValue
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
    
    // MARK: View Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        textField.delegate = self
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        leftAccessoryView = leftPaddingView
    }
    
    // MARK: Actions
    
    @IBAction private func textField(_ sender: UITextField) {
        delegate?.textFieldEditingChanged(self, textField: sender)
    }
    
    // MARK: Configure
    
    public func configureForSearch() {
        titleLabelText = nil
        textFieldPlaceholder = "Search"
        shouldShowSearchIconLeftView = true
        clearButtonMode = .always
        isCellSeparatorHidden = true
    }
    
}

// MARK: - UITextFieldDelegate

extension LabeledTextFieldTableViewCell: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing(self, textField: textField)
        textField.isActive = true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing(self, textField: textField)
        textField.isActive = false
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textFieldShouldChangeCharacters(self, textField: textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldBeginEditing(self, textField: textField) ?? true
    }
    
}

// MARK: - LabeledTextFieldTableViewCellDelegate

public protocol LabeledTextFieldTableViewCellDelegate: AnyObject {
    
    func textFieldDidBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField)
    func textFieldDidEndEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField)
    func textFieldShouldChangeCharacters(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textFieldShouldBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) -> Bool
    func textFieldEditingChanged(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField)

}

public extension LabeledTextFieldTableViewCellDelegate {
    func textFieldDidBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) { }
    func textFieldDidEndEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) { return }
    func textFieldShouldChangeCharacters(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { return true }
    func textFieldShouldBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) -> Bool { return true }
    func textFieldEditingChanged(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) { }
}
