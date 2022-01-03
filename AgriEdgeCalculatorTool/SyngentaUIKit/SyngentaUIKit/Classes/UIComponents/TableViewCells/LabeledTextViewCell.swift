//
//  LabeledTextViewCell.swift
//  SyngentaUIKit
//
//  Created by Garima on 22/10/19.
//

import UIKit

public class LabeledTextViewCell: UITableViewCell, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: BorderedTextView!
    @IBOutlet private weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorView: UIView!

    // MARK: Properties
    
    public weak var delegate: LabeledTextViewTableViewCellDelegate?
    
    public var titleLabelText: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
            if newValue == nil {
                stackViewTopConstraint?.constant = 0
            }
        }
    }
    
    public var textViewText: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
        }
    }
    
    public var textViewAttributedText: NSAttributedString? {
        get {
            return textView.attributedText
        }
        set {
            textView.attributedText = newValue
        }
    }
    
    public var textViewContentType: UITextContentType? {
        get {
            return textView.textContentType
        }
        set {
            textView.textContentType = newValue
        }
    }
    
    public var shouldTextViewBecomeFirstResponder: Bool = false {
        didSet {
            if shouldTextViewBecomeFirstResponder {
                textView.becomeFirstResponder()
            } else {
                textView.endEditing(true)
                textView.resignFirstResponder()
            }
        }
    }
    
    public var isTextViewEditable: Bool {
        get {
            return textView.isEditable
        }
        set {
            textView.isEditable = newValue
        }
    }
    
    public var shouldAutoEnableReturnKey: Bool {
        get {
            return textView.enablesReturnKeyAutomatically
        }
        set {
            textView.enablesReturnKeyAutomatically = newValue
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
        textView.delegate = self
    }
}

// MARK: - UITextViewDelegate

extension LabeledTextViewCell: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing(self, textView)
        textView.isActive = true
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldBeginEditing(self, textView) ?? true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing(self, textView)
        textView.isActive = false
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return delegate?.textViewShouldEndEditing(self, textView) ?? true
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.textViewDidChangeSelection(self, textView)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewDidChange(self, textView)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return delegate?.textView(self, textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegate?.textView(self, textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegate?.textView(self, textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
    }
    
    public func textViewDidChange(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView) {
        delegate?.textViewDidChange(labeledTextViewCell, textView)
    }
    
}

// MARK: - LabeledTextViewTableViewCell Protocol

public protocol LabeledTextViewTableViewCellDelegate: AnyObject {
    
    func textViewDidBeginEditing(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView)
    
    func textViewDidEndEditing(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView)
    
    func textView(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    
    func textViewDidChange(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView) 
    
 }

public extension LabeledTextViewTableViewCellDelegate {
    
    func textViewShouldBeginEditing(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidChangeSelection(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView) {}
    
    func textViewDidChange(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView) {}
    
    func textView(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textView(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    func textView(_ labeledTextViewCell: LabeledTextViewCell, _ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
}
