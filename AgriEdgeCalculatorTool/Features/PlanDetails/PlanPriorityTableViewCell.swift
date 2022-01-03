//
//  PlanPriorityTableViewCell.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 6/23/21.
//  Copyright © 2021 Syngenta. All rights reserved.
//

import UIKit

public protocol PlanPriorityTableViewCellDelegate: AnyObject {
    func didChangePlanPriority(isPriority: Bool)
}

class PlanPriorityTableViewCell: UITableViewCell, NibLoadable {

    // MARK: - UITableViewCell
    
    // MARK: - Internal properties
    
    weak var delegate: PlanPriorityTableViewCellDelegate?
    var isPriority: Bool = false {
        didSet {
            checkmarkImageView.image = isPriority ? UIImage(systemName: "checkmark.rectangle") : UIImage(systemName: "rectangle")
            label.text = isPriority ? "Selected" : "Not selected"
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private var checkmarkImageView: UIImageView!
    @IBOutlet private var label: UILabel!
    
    // MARK: - Actions
    
    @IBAction private func buttonAction(_ sender: Any) {
        isPriority.toggle()
        delegate?.didChangePlanPriority(isPriority: isPriority)
    }
    
    // MARK: - Private properties

}
