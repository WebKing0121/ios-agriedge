//
//  PlanConfidenceTableViewCell.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 6/10/20.
//  Copyright © 2020 Syngenta. All rights reserved.
//

import UIKit

class PlanConfidenceTableViewCell: UITableViewCell, NibLoadable {

    // MARK: - UITableViewCell
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        borderView.layer.borderWidth = 2
        borderView.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    // MARK: - Internal properties
    
    var planConfidence: PlanConfidence = .default {
        didSet {
            borderView.layer.borderColor = planConfidence.color.cgColor
            colorIndicatorView.backgroundColor = planConfidence.color
            confidenceLabel.text = planConfidence.title
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private var borderView: UIView!
    @IBOutlet private var colorIndicatorView: UIView!
    @IBOutlet private var confidenceLabel: UILabel!
    
}
