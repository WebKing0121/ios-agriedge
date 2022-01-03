//
//  TabbedContainerItem.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 11/18/19.
//

import UIKit

public struct TabbedContainerItem {
    
    let tabTitle: String
    let viewController: UIViewController
    
    public init(tabTitle: String, viewController: UIViewController) {
        self.tabTitle = tabTitle
        self.viewController = viewController
    }
    
}
