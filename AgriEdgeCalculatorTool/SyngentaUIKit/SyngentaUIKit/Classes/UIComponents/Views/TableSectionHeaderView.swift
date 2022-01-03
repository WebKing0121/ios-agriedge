//
//  TableSectionHeaderView.swift
//  SyngentaUIKit
//
//  Created by lloyd on 6/12/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class TableSectionHeaderView: UITableViewHeaderFooterView, NibLoadable {
    
    // MARK: Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var separatorView: UIView!
    
    // MARK: Properties
    
    public weak var delegate: TableSectionHeaderViewDelegate?
    
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
                isSubtitleLabelHidden = false
                subtitleLabel.text = newValue
            } else {
                isSubtitleLabelHidden = true
            }
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
    
    public var isPlusButtonHidden: Bool {
        get {
            return plusButton.isHidden
        }
        set {
            plusButton.isHidden = newValue
        }
    }
    
    public var isMinusButtonHidden: Bool {
        get {
            return minusButton.isHidden
        }
        set {
            minusButton.isHidden = newValue
        }
    }
    
    public var isSeparatorViewHidden: Bool {
        get {
            return separatorView.isHidden
        }
        set {
            separatorView.isHidden = newValue
        }
    }
    
    // MARK: View Life Cycle
    
    public override func draw(_ rect: CGRect) {
        drawShadow(on: .top)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        isSubtitleLabelHidden = true
        isPlusButtonHidden = true
        isMinusButtonHidden = true
        isSeparatorViewHidden = true
    }
    
    // MARK: Actions
    
    @IBAction private func tapPlusButton(_ sender: UIButton) {
        delegate?.didTapPlusButton(self, sender: sender)
    }
    
    @IBAction private func tapMinusButton(_ sender: UIButton) {
        delegate?.didTapMinusButton(self, sender: sender)
    }
    
}

// MARK: - TableSectionHeaderViewDelegate

public protocol TableSectionHeaderViewDelegate: AnyObject {
    func didTapPlusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton)
    func didTapMinusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton)
}

public extension TableSectionHeaderViewDelegate {
    func didTapPlusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton) {}
    func didTapMinusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton) {}
}
