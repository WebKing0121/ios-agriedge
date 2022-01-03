//
//  SearchTableViewControllerPresenting.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 9/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public protocol SearchTableViewControllerPresenting: AnyObject {
    func pushSearchViewController<T: NameSearchable>(title: String, dataSource: [T])
    func didSelectItem<T: NameSearchable>(_ searchTableViewController: SearchTableViewController<T>, item: T)
}

public extension SearchTableViewControllerPresenting where Self: UIViewController {
    
    func pushSearchViewController<T: NameSearchable>(title: String, dataSource: [T]) {
        let searchTableViewController = SearchTableViewController<T>(title: title, dataSource: dataSource)
        searchTableViewController.delegate = self
        navigationController?.pushViewController(searchTableViewController, animated: true)
    }
    
}
