//
//  SearchTableViewController.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/24/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class SearchTableViewController<T: NameSearchable>: UITableViewController, UISearchResultsUpdating {
    
    // MARK: Init
    
    public init(title: String, dataSource: [T]) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.dataSource = dataSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Properties
    
    public weak var delegate: SearchTableViewControllerPresenting?
    
    private var dataSource = [T]()
    private var filteredDataSource = [T]()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.placeholder = "Search"
        return controller
    }()
    
    // MARK: Searching
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isSearching: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    private func filterContent(for searchText: String) {
        filteredDataSource = dataSource.filter({
            (type: T) -> Bool in
            
            return type.displayName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    // MARK: View Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - UITableViewDelegate & UITableViewDataSource

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredDataSource.count
        }
        return dataSource.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if isSearching {
            cell.textLabel?.text = filteredDataSource[indexPath.row].displayName
        } else {
            cell.textLabel?.text = dataSource[indexPath.row].displayName
        }
        
        return cell
    }
        
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = isSearching ? filteredDataSource[indexPath.row] : dataSource[indexPath.row]
        delegate?.didSelectItem(self, item: selectedItem)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UISearchResultsUpdating

    public func updateSearchResults(for searchController: UISearchController) {
        filterContent(for: searchController.searchBar.text!)
    }
}
