//
//  TabbedContainerTabView.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 11/13/19.
//

import UIKit

public final class TabbedContainerTabView: UIView, NibLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var tabButton: UIButton!
    
    // MARK: Public Properties
    
    public weak var delegate: TabbedContainerTabViewDelegate?
    
    public var isSelected: Bool = false {
        didSet {
            if isSelected {
                tabButton.setTitleColor(SemanticCustomColor.primaryInk.uiColor, for: .normal)
            } else {
                tabButton.setTitleColor(SemanticCustomColor.secondaryInk.uiColor, for: .normal)
            }
        }
    }
    
    // MARK: Configure
    
    public func configure(tabTitle: String) {
        tabButton.setTitle(tabTitle, for: .normal)
    }
    
    // MARK: Actions
    
    @IBAction private func selectTab(_ sender: UIButton) {
        delegate?.didSelectTab(self)
    }
    
}

public protocol TabbedContainerTabViewDelegate: AnyObject {
    func didSelectTab(_ sender: TabbedContainerTabView)
}
