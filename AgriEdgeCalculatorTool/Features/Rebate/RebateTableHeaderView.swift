//
//  RebateTableHeaderView.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 8/13/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

class RebateTableHeaderView: UITableViewHeaderFooterView, NibLoadable {

    // MARK: Outlets
    
    @IBOutlet private weak var riskManagementCostShareLabel: UILabel!
    @IBOutlet private weak var rebateAmountLabel: UILabel!
    @IBOutlet private weak var seeMoreButton: UIButton!
    @IBOutlet private weak var background: UIView!
    
    // MARK: View LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        background.backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
        riskManagementCostShareLabel.textColor = SemanticCustomColor.secondaryInk.uiColor
        rebateAmountLabel.textColor = SemanticCustomColor.primaryInk.uiColor
    }
    
    // MARK: Properties
    
    weak var delegate: RebateTableHeaderViewDelegate?
    
    var rebateAmountLabelText: String? {
        get {
            return rebateAmountLabel.text
        }
        set {
            rebateAmountLabel.text = newValue
        }
    }
    
    var seeMoreButtonLabelText: String? {
        get {
            return seeMoreButton.titleLabel?.text
        }
        set {
            seeMoreButton.setTitle(newValue, for: .normal)
        }
    }
    
    var seeMoreButtonIsHidden: Bool {
        get {
            return seeMoreButton.isHidden
        }
        set {
            seeMoreButton.isHidden = newValue
        }
    }
    
    // MARK: Action
    
    @IBAction private func seeMoreButtonAction(_ sender: UIButton) {
        delegate?.didTapSeeMore(self)
    }
}

protocol RebateTableHeaderViewDelegate: AnyObject {
    func didTapSeeMore(_ rebateTableHeaderView: RebateTableHeaderView)
}
