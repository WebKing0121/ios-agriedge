//
//  AlertPresenting.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/11/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public protocol AlertPresenting {
    func showAlert(title: String?, message: String?, completion: (() -> Void)?)
    func showChoiceAlert(title: String?, message: String?, alertActions: [UIAlertAction]?, completion: (() -> Void)?)
    func showChoiceActionSheet(title: String?, message: String?, alertActions: [UIAlertAction]?, completion: (() -> Void)?, barButtonItem: UIBarButtonItem?)
    func showNoConnectionAlert(completion: (() -> Void)?)
}

public extension AlertPresenting where Self: UIViewController {
    
    func showAlert(title: String? = nil, message: String? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let submit = UIAlertAction(title: "OK", style: .default)
        alert.addAction(submit)
        present(alert, animated: true, completion: completion)
    }
    
    func showChoiceAlert(title: String? = nil, message: String? = nil, alertActions: [UIAlertAction]? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertActions?.forEach({ alert.addAction($0) })
        present(alert, animated: true, completion: completion)
    }
    
    func showChoiceActionSheet(title: String? = nil, message: String? = nil, alertActions: [UIAlertAction]? = nil, completion: (() -> Void)? = nil, barButtonItem: UIBarButtonItem? = nil) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.barButtonItem = barButtonItem
        }
        
        alertActions?.forEach({ actionSheet.addAction($0) })
        present(actionSheet, animated: true, completion: completion)
    }
    
    func showNoConnectionAlert(completion: (() -> Void)? = nil) {
        showAlert(title: "Network Connection Error", message: "Please check your network connection and try again.", completion: completion)
    }
    
}
