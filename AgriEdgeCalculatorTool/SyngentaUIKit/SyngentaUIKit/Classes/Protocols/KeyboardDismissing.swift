//
//  KeyboardDismissing.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/8/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public protocol KeyboardDismissing {
    func addKeyboardDismissGestureRecognizer()
    func removeKeyboardDismissGestureRecognizer()
}

public extension KeyboardDismissing where Self: UIViewController {
    
    func addKeyboardDismissGestureRecognizer() {
        let dismissKeyboardRecognizer = UITapGestureRecognizer(target: self, action: .keyboardDismissed)
        view.addGestureRecognizer(dismissKeyboardRecognizer)
    }
    
    func removeKeyboardDismissGestureRecognizer() {
        view.gestureRecognizers?.removeAll()
    }
    
}

public extension UIViewController {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

public extension Selector {
    static let keyboardDismissed = #selector(UIViewController.dismissKeyboard)
}
