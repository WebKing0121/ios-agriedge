//
//  IconLabeledTableViewCell.swift
//  Pods-SyngentaUIKit_Example
//
//  Created by Shraddh on 04/11/19.
//

import UIKit

public class IconLabeledTableViewCell: UITableViewCell, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    
    // MARK: View Life Cycle
    
    public override func prepareForReuse() {
        separatorView.isHidden = false
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        if shouldShowTopShadow {
            drawShadow(on: .top)
        }
    }
    
    // MARK: Configure
    
    public func configure(titleLabelText: String? = nil,
                          imageIconName: String,
                          isSeparatorHidden: Bool = false,
                          needsTopShadow: Bool = false) {
        titleLabel.text = titleLabelText
        isCellSeparatorHidden = isSeparatorHidden
        let bundle = Bundle(for: IconLabeledTableViewCell.self)
        let image = UIImage(named: imageIconName, in: bundle, compatibleWith: nil)
        iconImageView.image = image
        shouldShowTopShadow = needsTopShadow
    }
    
    // MARK: Public Properties
    
    public var titleLabelText: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
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
    
    // MARK: Private Properties
    
    private var shouldShowTopShadow = false
    
}
