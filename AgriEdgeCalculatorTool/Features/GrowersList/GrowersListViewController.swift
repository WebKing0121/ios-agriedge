//
//  GrowersListViewController.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/11/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Reachability

class GrowersListViewController: BaseTableViewController, AnalyticsTracking, DataUploading {
    
    // MARK: Public Properties
    
    var growersDataSource = [Grower]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: Private Properties
    
    private let refreshControl = UIRefreshControl()
    private var filteredGrowersDataSource = [Grower]()
    private var isSearching = false
    
    private lazy var headerView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "My Growers"
        headerView.isPlusButtonHidden = false
        headerView.delegate = self
        return headerView
    }()
    
    private lazy var searchCell: LabeledTextFieldTableViewCell = {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.configureForSearch()
        cell.delegate = self
        return cell
    }()
    
    private lazy var emptyListInfoCell: InfoLabelTableViewCell = {
        let cell = InfoLabelTableViewCell.fromNib
        cell.infoLabelText = "No growers added yet.\nTap the ‘+’ to add a grower."
        return cell
    }()
    
    private var noSearchResultsInfoCell: InfoLabelTableViewCell {
        let cell = InfoLabelTableViewCell.fromNib
        cell.infoLabelText = "No growers found with that name."
        return cell
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalytics(screen: .growersList)
        observeReachability()
        tableView.register(LabeledTableViewCell.nib, forCellReuseIdentifier: LabeledTableViewCell.nibName)
        refreshControl.tintColor = .teal500
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self,
                                 action: #selector(refreshGrowersTableView),
                                 for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGrowersFromPersistence()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
    }
    
    @objc private func willEnterForeground(_ notification: Notification) {
        OktaSessionManager.shared.refreshTokensIfNeeded {
            self.fetchGrowersFromServiceIfConnected { growers in
                if growers != nil {
                    self.fetchGrowersFromPersistence()
                }
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController,
            let growerDetailsVC = navVC.topViewController as? GrowerDetailsViewController {
            growerDetailsVC.delegate = self
        } else if let growerProfileVC = segue.destination as? GrowerProfileViewController,
            let growerIndexPath = sender as? IndexPath {
            let growersListDataSource = isSearching ? filteredGrowersDataSource : growersDataSource
            growerProfileVC.grower = growersListDataSource[growerIndexPath.row]
        }
    }
    
    @IBAction private func unwindToGrowersListViewController(_ segue: UIStoryboardSegue) {
        fetchGrowersFromPersistence()
    }
    
    private func navigateToGrowerDetails() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "GrowerDetailsSegue", sender: self)
        }
    }
    
    // MARK: Fetch Growers
    
    private func fetchGrowersFromPersistence() {
        guard let growers = PersistenceLayer().fetch(GrowerObject.self) else {
            growersDataSource = []
            return
        }
        growersDataSource = growers.map({
            (growerObject: GrowerObject) -> Grower in
            return Grower(growerObject: growerObject)
        }).sorted(by: { (growerA, growerB) -> Bool in
            return growerA.farmName.lowercased() < growerB.farmName.lowercased()
        })
    }
    
    private func fetchGrowersFromService(completion: @escaping ([Grower]?) -> Void) {
        let userID = PersistenceLayer().fetch(UserObject.self)?.first?.userID ?? ""
        OktaSessionManager.shared.refreshTokensIfNeeded(inViewController: self) {
            ServiceLayer().fetch(GrowersEndpoint.fetchGrowers(userID: userID, persistCompletion: nil), cleanPersist: true) {
                (result: (ServiceResult<[Grower]>)) in
                switch result {
                case .success(let growers):
                    completion(growers.sorted(by: { (growerA, growerB) -> Bool in
                        return growerA.farmName.lowercased() < growerB.farmName.lowercased()
                    }))
                    self.logAnalytics(event: .loadGrowersList, parameters: ["number_of_growers": String(growers.count)])
                case .failure(let error):
                    log(error: "error downloading growers from refresh: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    private func fetchGrowersFromServiceIfConnected(completion: @escaping ([Grower]?) -> Void) {
        guard ReachabilityManager.shared.isNetworkReachable else {
            completion(nil)
            return
        }
        fetchGrowersFromService(completion: completion)
    }
    
    @objc func refreshGrowersTableView() {
        guard ReachabilityManager.shared.isNetworkReachable else {
            showNoConnectionAlert {
                self.refreshControl.endRefreshing()
            }
            return
        }
        fetchGrowersFromService { growers in
            if growers != nil {
                self.fetchGrowersFromPersistence()
            } else {
                self.showAlert(title: AlertConstants.connectionErrorTitle,
                               message: AlertConstants.serverErrorMessage,
                               completion: nil)
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    private func showNoConnectionAlert(completion: (() -> Void)? = nil) {
        showAlert(title: "Network Connection Error",
                  message: "Please check your network connection and try again.",
                  completion: completion)
    }
    
}

// MARK: - TableView Delegate & Data Source

extension GrowersListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TableViewSection(rawValue: section) else { return 0 }
        switch section {
        case .search:
            return growersDataSource.isEmpty ? 0 : 1
        case .growersList:
            if isSearching {
                return filteredGrowersDataSource.isEmpty ? 1 : filteredGrowersDataSource.count
            } else {
                return growersDataSource.isEmpty ? 1 : growersDataSource.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = TableViewSection(rawValue: section) else { return nil }
        switch section {
        case .search:
            return headerView
        case .growersList:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let section = TableViewSection(rawValue: section) else { return nil }
        switch section {
        case .search:
            return nil
        case .growersList:
            return TableSectionFooterView.fromNib
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = TableViewSection(rawValue: section) else { return 0 }
        switch section {
        case .search:
            return BaseTableViewConstants.headerHeight
        case .growersList:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let section = TableViewSection(rawValue: section) else { return 0 }
        switch section {
        case .search:
            return 0
        case .growersList:
            return BaseTableViewConstants.footerHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableViewSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .search:
            return searchCell
        case .growersList:
            if growersDataSource.isEmpty {
                return emptyListInfoCell
            } else {
                if isSearching && filteredGrowersDataSource.isEmpty {
                    return noSearchResultsInfoCell
                }

                let growersListDataSource = isSearching ? filteredGrowersDataSource : growersDataSource
                let cell = LabeledTableViewCell.dequeue(for: tableView, at: indexPath)
                let cellTitle = "\(growersListDataSource[indexPath.row].farmName)"
                var acreage = NSMutableAttributedString(string: "--")
                
                if growersListDataSource[indexPath.row].totalPlantedAcreage > 0 {
                    acreage = NSMutableAttributedString(string: String(format: "%.0f", growersListDataSource[indexPath.row].totalPlantedAcreage))
                }
                acreage.append(NSAttributedString(string: " acres", attributes: [NSAttributedString.Key.foregroundColor: UIColor.ink700]))
                
                cell.configure(titleLabelText: cellTitle, isSeparatorHidden: indexPath.isLastOf(growersListDataSource))
                cell.accessoryLabelAttributedText = acreage
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = TableViewSection(rawValue: indexPath.section) else { return }
        switch section {
        case .search:
            return
        case .growersList:
            performSegue(withIdentifier: "GrowerProfileSegue", sender: indexPath)
        }
    }
    
    private enum TableViewSection: Int {
        case search
        case growersList
    }
    
}

// MARK: - GrowerDetailsViewControllerDelegate

extension GrowersListViewController: GrowerDetailsViewControllerDelegate {
    
    func didAddGrower(_ viewController: GrowerDetailsViewController, grower: Grower) {
        growersDataSource.append(grower)
        growersDataSource = growersDataSource.sorted(by: { (growerA, growerB) -> Bool in
            return growerA.farmName.lowercased() < growerB.farmName.lowercased()
        })
    }
    
}

// MARK: - TableSectionHeaderViewDelegate

extension GrowersListViewController: TableSectionHeaderViewDelegate {
    
    func didTapPlusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton) {
        logAnalytics(event: .addNewGrower)
        navigateToGrowerDetails()
    }
    
}

// MARK: - ReachabilityObserving

extension GrowersListViewController: ReachabilityObserving {
    
    func reachabilityChanged(status: Reachability.Connection) {
        switch status {
        case .wifi, .cellular:
            log(info: "network reachable on \(self)")
        case .none:
            log(info: "network not reachable on \(self)")
        }
    }
    
}

// MARK: - LabeledTextFieldTableViewCellDelegate

extension GrowersListViewController: LabeledTextFieldTableViewCellDelegate, KeyboardDismissing {
    
    func textFieldDidBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) {
        addKeyboardDismissGestureRecognizer()
    }
    
    func textFieldDidEndEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) {
        removeKeyboardDismissGestureRecognizer()
    }
    
    func textFieldEditingChanged(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) {
        guard let searchString = textField.text else {
            isSearching = false
            return
        }
        
        isSearching = !searchString.isEmpty
    
        filteredGrowersDataSource = growersDataSource.filter({ grower in
            var growerFarmName = grower.farmName.lowercased()
            var searchString = searchString.lowercased()
            
            growerFarmName.alphanumerical()
            searchString.alphanumerical()
            
            return growerFarmName.contains(searchString)
        })
        
        tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }

}

// MOVE TO SYNGENTA UIKIT

extension String {
    
    mutating func alphanumerical() {
        self = self.filter { (char) -> Bool in
            return char.isNumber || char.isLetter
        }
    }
    
}
