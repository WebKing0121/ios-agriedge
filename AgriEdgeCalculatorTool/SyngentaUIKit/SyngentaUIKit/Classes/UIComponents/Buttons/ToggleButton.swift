//
//  ToggleButton.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/10/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class ToggleButton: UIButton {
    
    // MARK: View Life Cycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }

    public override func draw(_ rect: CGRect) {
        layer.borderWidth = 1
        layer.cornerRadius = 16
        tintColor = .teal500
        setImage(nil, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        configureUI()
    }
    
    // MARK: Initializers
    
    convenience init(frame: CGRect, toggleType: ToggleType) {
        self.init(frame: frame)
        self.toggleType = toggleType
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Public Overrides
    
    public override var isSelected: Bool {
        didSet {
            layoutSubviews()
        }
    }
    
    // MARK: Configure
    
    private var toggleType: ToggleType = .checkmark
    
    private func configureUI() {
        layer.masksToBounds = true

        if self.isSelected {
            let bundle = Bundle(for: ToggleButton.self)
            
            var image: UIImage?
            switch toggleType {
            case .checkmark:
                image = UIImage(named: "checkmark", in: bundle, compatibleWith: nil)
            case .radio:
                image = UIImage(named: "emptyCircle", in: bundle, compatibleWith: nil)
            }
            setImage(image, for: .normal)
            
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)
            backgroundColor = .teal100
            setTitleColor(.teal500, for: .normal)
            tintColor = .teal500
            layer.borderColor = UIColor.teal500.cgColor
        } else {
            setImage(nil, for: .normal)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            backgroundColor = .neutral300
            setTitleColor(.ink700, for: .normal)
            layer.borderColor = UIColor.neutral700.cgColor
        }
    }
    
}

public enum ToggleType {
    case checkmark
    case radio
}
