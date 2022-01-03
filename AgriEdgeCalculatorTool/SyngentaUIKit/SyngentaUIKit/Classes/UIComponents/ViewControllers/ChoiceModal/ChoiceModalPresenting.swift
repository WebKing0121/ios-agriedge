//
//  ChoiceModalPresenting.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 9/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public protocol ChoiceModalPresenting: AnyObject {
    func showChoiceModal(withInfo: ChoiceModalInfo)
    func choiceModalDidSelectItem(_ choiceModalViewController: ChoiceModalViewController, selection: String?)
}

public extension ChoiceModalPresenting where Self: UIViewController {
    
    func showChoiceModal(withInfo info: ChoiceModalInfo) {
        let choiceModalViewController = ChoiceModalViewController.fromStoryboard
        choiceModalViewController.choiceModalInfo = info
        choiceModalViewController.delegate = self
        present(choiceModalViewController, animated: true, completion: nil)
    }
    
}
