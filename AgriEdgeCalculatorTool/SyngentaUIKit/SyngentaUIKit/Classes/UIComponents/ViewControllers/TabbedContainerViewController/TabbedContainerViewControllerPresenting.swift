//
//  TabbedContainerViewControllerPresenting.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 11/13/19.
//

import UIKit

public protocol TabbedContainerViewControllerPresenting: AnyObject {
    func pushTabbedContainerViewController(title: String)
    func tabbedContainerViewControllerContent(for tabbedViewController: TabbedContainerViewController) -> ([TabbedContainerItem])
}

public extension TabbedContainerViewControllerPresenting where Self: UIViewController {
    
    func pushTabbedContainerViewController(title: String) {
        let tabbedContainerViewController = TabbedContainerViewController.fromStoryboard
        tabbedContainerViewController.title = title
        tabbedContainerViewController.delegate = self
        navigationController?.pushViewController(tabbedContainerViewController, animated: true)
    }
    
    func presentTabbedContainerViewController(title: String) {
        let tabbedContainerViewController = TabbedContainerViewController.fromStoryboard
        tabbedContainerViewController.title = title
        tabbedContainerViewController.delegate = self
        
        let closeButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissModalPresentation))
        tabbedContainerViewController.navigationItem.leftBarButtonItem = closeButton

        let tabbedContainerViewNavigationController = UINavigationController(rootViewController: tabbedContainerViewController)
        tabbedContainerViewNavigationController.modalPresentationStyle = .fullScreen

        present(tabbedContainerViewNavigationController, animated: true, completion: nil)
    }

}

public protocol TabbedContainerViewControllerNavigating: AnyObject {
    func tabbedContainerDidSelectNextController()
    func tabbedContainerDidSelectPreviousController()
}
