//
//  LabeledTextFieldAccessoryTableViewCell.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 10/17/19.
//

import UIKit

public class LabeledTextFieldAccessoryTableViewCell: UITableViewCell, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var textField: BorderedTextField!
    @IBOutlet private weak var separatorView: UIView!
    
    // MARK: Properties
    
    public weak var delegate: LabeledTextFieldAccessoryTableViewCellDelegate?
    
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
                subtitleLabel.isHidden = true
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
    
    public var shouldShowAcresAccessoryView: Bool = false {
        didSet {
            if shouldShowAcresAccessoryView {
                let acresLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 46, height: 24))
                acresLabel.font = .systemFont(ofSize: 15)
                acresLabel.text = "acres"
                acresLabel.textColor = .ink700
                let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 24))
                rightView.addSubview(acresLabel)
                
                textField.rightViewMode = .always
                textField.rightView = rightView
            } else {
                textField.rightView = nil
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
    
    public var rightAccessoryView: UIView? {
        get {
            return textField.rightView
        }
        set {
            textField.rightViewMode = .always
            textField.rightView = newValue
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
    
}

// MARK: - UITextFieldDelegate

extension LabeledTextFieldAccessoryTableViewCell: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = SemanticCustomColor.tableBackground.uiColor
        delegate?.textFieldDidBeginEditing(self, textField: textField)
        textField.isActive = true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
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

// MARK: - LabeledTextFieldAccessoryTableViewCellDelegate

public protocol LabeledTextFieldAccessoryTableViewCellDelegate: AnyObject {
    
    func textFieldDidBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField)
    func textFieldDidEndEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField)
    func textFieldShouldChangeCharacters(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textFieldShouldBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField) -> Bool

}

public extension LabeledTextFieldTableViewCellDelegate {
    func textFieldDidBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField) { }
    func textFieldDidEndEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField) { return }
    func textFieldShouldChangeCharacters(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { return true }
    func textFieldShouldBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField) -> Bool { return true }
}
