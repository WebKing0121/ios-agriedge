//
//  GrowerProfileViewController.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/3/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Pulley

class GrowerProfileViewController: BaseTableViewController, DataUploading, AnalyticsTracking {
    
    // MARK: Public Properties
    
    var grower: Grower?
    
    // MARK: Private Properties
    
    private var pulleyVC: PulleyViewController?
    
    private var planDataSource = [Plan]() {
        didSet {
            plansSectionHeaderView.isMinusButtonHidden = (planDataSource.count > 0) ? false : true
        }
    }
    
    private var shouldEditPlans: Bool = false {
        didSet {
            tableView.setEditing(shouldEditPlans ? true : false, animated: true)
        }
    }
    
     // MARK: Cells
    
    private lazy var cropsSectionHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "My Crops"
        return headerView
    }()
    
    private lazy var plansSectionHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "My Plans"
        headerView.delegate = self
        return headerView
    }()
    
    private lazy var emptyCropsListInfoCell: InfoLabelTableViewCell = {
        let cell = InfoLabelTableViewCell.fromNib
        cell.infoLabelText = "No crops exist for this Grower.\nPlease add crops before creating new Plans."
        return cell
    }()
    
    private lazy var emptyCropsAddCropCell: StyledButtonTableViewCell = {
        let cell = StyledButtonTableViewCell.fromNib
        cell.buttonType = (.tertiary, .teal)
        cell.buttonTitleLabelText = "Add Crop"
        cell.delegate = self
        return cell
    }()

    private lazy var emptyPlansListInfoCell: InfoLabelTableViewCell = {
        let cell = InfoLabelTableViewCell.fromNib
        cell.infoLabelText = "No plans created."
        return cell
    }()
    
    private lazy var navigationBarView: LabeledNavigationBarView? = {
        let navBarView = LabeledNavigationBarView.fromNib
        return navBarView
    }()
    
    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalytics(screen: .growerProfile)
        tableView.register(LabeledTableViewCell.nib, forCellReuseIdentifier: LabeledTableViewCell.nibName)
        tableView.register(PlanTableViewCell.nib, forCellReuseIdentifier: PlanTableViewCell.nibName)
        guard let navigationBarView = navigationBarView else { return }
        navigationItem.titleView = navigationBarView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let predicate = NSPredicate(format: "growerID = %@", grower?.growerID ?? "")
        planDataSource = PersistenceLayer().fetch(PlanObject.self, predicate: predicate, sortedBy: PlanObject.isPriorityKeyPath, ascending: false)?.map({ Plan(planObject: $0) }) ?? []
        grower?.plans = planDataSource
        tableView.reloadData()
        configureNavBarView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shouldEditPlans = false
    }
    
    // MARK: Navigation
    
    private func navigateToPlanDetails() {
        logAnalytics(event: .createNewPlan)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "PlansDetailsSegue", sender: self)
        }
    }
    
    @IBAction private func editGrower(_ sender: Any) {
        logAnalytics(event: .editGrower)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "GrowerDetailsSegue", sender: self)
        }
    }
    
    @IBAction func backToGrowerList(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController,
            let growerDetailsVC = navVC.topViewController as? GrowerDetailsViewController,
            let editGrower = self.grower {
            growerDetailsVC.grower = editGrower
            growerDetailsVC.isEditingGrower = true
            growerDetailsVC.delegate = self
        } else {
            pulleyVC = segue.destination as? PulleyViewController
            pulleyVC?.loadViewIfNeeded()
            guard let planDetailsViewController = pulleyVC?.primaryContentViewController as? PlanDetailsViewController,
                let rebateViewController = pulleyVC?.drawerContentViewController as? RebateViewController else { return }
            rebateViewController.delegate = self
            rebateViewController.pulleyDrawerDelegate = planDetailsViewController
            planDetailsViewController.delegate = rebateViewController
            planDetailsViewController.pulleyDelegate = self
            guard let grower = grower else { return }
            planDetailsViewController.grower = grower
            if let indexPath = sender as? IndexPath {
                planDetailsViewController.currentPlan = planDataSource[indexPath.row]
                planDetailsViewController.isEditingPlan = true
            }
        }
    }

    private func configureNavBarView() {
        guard let grower = grower else { return }
        navigationBarView?.configure(titleLabelText: "\(grower.farmName)", subtitleLabelText: "Zone: \(grower.zoneID.zoneDisplayNameFromID() ?? "")")
    }
}

// MARK: - TableView Delegate & Data Source

extension GrowerProfileViewController {
    
    // MARK: Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TableViewSection(rawValue: section) else { return 0 }

        switch section {
        case .crops:
            if grower?.crops?.isEmpty ?? true {
                return 2
            } else {
                return grower?.crops?.count ?? 0
            }
        case .plans:
            return planDataSource.isEmpty ? 1 : planDataSource.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = TableViewSection(rawValue: section) else { return UIView() }

        switch section {
        case .crops:
            return cropsSectionHeaderView
        case .plans:
            if grower?.crops?.isEmpty ?? true {
                plansSectionHeaderView.isPlusButtonHidden = true
                plansSectionHeaderView.isMinusButtonHidden = true
            } else {
                plansSectionHeaderView.isPlusButtonHidden = false
                plansSectionHeaderView.isMinusButtonHidden = (planDataSource.count > 0) ? false : true
            }

            return plansSectionHeaderView
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableViewSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .crops:
            if grower?.crops?.isEmpty ?? true {
                if indexPath.row == 0 {
                    return emptyCropsListInfoCell
                } else {
                    return emptyCropsAddCropCell
                }
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LabeledTableViewCell.nibName, for: indexPath) as? LabeledTableViewCell,
                    let growerCrops = grower?.crops else {
                        return UITableViewCell()
                }
                let cropName = growerCrops[indexPath.row].cropID.cropNameFromID()
                let acreage = NSMutableAttributedString(string: String(format: "%.0f", growerCrops[indexPath.row].plantedAcreage))
                acreage.append(NSAttributedString(string: " acres", attributes: [NSAttributedString.Key.foregroundColor: UIColor.ink700]))
                cell.configure(titleLabelText: cropName, isSeparatorHidden: indexPath.isLastOf(growerCrops))
                cell.accessoryLabelAttributedText = acreage
                cell.isUserInteractionEnabled = false
                return cell
            }
        case .plans:
            if planDataSource.isEmpty {
                return emptyPlansListInfoCell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PlanTableViewCell.nibName, for: indexPath) as? PlanTableViewCell
                    else {
                    return UITableViewCell()
                }
                let plan = planDataSource[indexPath.row]
                let subtitleText = ("\(plan.seedApplications.count) seed applications, \(plan.applications.count) cp applications")
                cell.configure(titleLabelText: plan.displayName, isPriority: plan.isPriorityBool, subtitleViewColor: plan.planConfidence.color, subtitleLabelText: subtitleText, accessoryLabelText: plan.rebate.totalEstimatedRebateTotal, isSeparatorHidden: indexPath.isLastOf(planDataSource))
                
                return cell
            }
        }
    }
    
    enum TableViewSection: Int {
        case crops
        case plans
    }
    
    // MARK: Delegate Section
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        logAnalytics(event: .viewExistingPlan)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "PlansDetailsSegue", sender: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = TableViewSection(rawValue: indexPath.section) else { return false }
        switch section {
        case .plans:
            return planDataSource.isEmpty ? false : true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let duplicateAction = UIContextualAction(style: .normal, title: "Duplicate") { (_, _, completionHandler) in
            var planToDuplicate = self.planDataSource[indexPath.row]
            planToDuplicate.planID = UUID().uuidString
            planToDuplicate.rebate.rebateID = UUID().uuidString
            planToDuplicate.isPriority = 0 //we can't have more than 1 priority plan, so initialize this to false
            planToDuplicate.applications = planToDuplicate.applications.map({ (applicationToChange) -> Application in
                var application = applicationToChange
                application.applicationID = UUID().uuidString
                return application
            })
            planToDuplicate.seedApplications = planToDuplicate.seedApplications.map({ (seedApplicationToDuplicate) -> SeedApplication in
                var seedApplication = seedApplicationToDuplicate
                seedApplication.seedApplicationID = UUID().uuidString
                return seedApplication
            })
            DualPersistenceLayer(shouldAddToUpdateRealm: true).save(PlanObject().project(from: planToDuplicate)) { result in
                switch result {
                case .success:
                    self.planDataSource.append(planToDuplicate)
                    self.tableView.insertRows(at: [IndexPath(row: (self.planDataSource.count - 1), section: indexPath.section)], with: .fade)
                    OktaSessionManager.shared.refreshTokensIfNeeded {
                        self.uploadPlans()
                    }
                    completionHandler(true)
                case .failure:
                    self.showAlert(title: "Error Saving Plan", message: "Please try again.")
                    completionHandler(false)
                }
            }
        }
        duplicateAction.backgroundColor = UIColor.blue500
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            let confirm = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.logAnalytics(event: .deletePlan)
                self.deleteAtIndexPath(indexPath: indexPath)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            self.showChoiceAlert(title: "Are you sure you want to delete this plan?", message: "", alertActions: [confirm, cancel], completion: nil)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [duplicateAction, deleteAction])
    }
    
    // MARK: Delete Helper
    
    private func deleteAtIndexPath(indexPath: IndexPath) {
        let planObjectToDelete = PlanObject().project(from: planDataSource[indexPath.row])
        planObjectToDelete.shouldDelete = true
        DualPersistenceLayer(shouldAddToUpdateRealm: true).save(planObjectToDelete) { result in
            switch result {
            case .success:
                let planID = planObjectToDelete.planID
                OktaSessionManager.shared.refreshTokensIfNeeded {
                    self.deletePlans()
                }
                if let rebateToDelete = planObjectToDelete.rebate {
                    PersistenceLayer().delete(rebateToDelete)
                }
                planObjectToDelete.applications.forEach({ application in
                    PersistenceLayer().delete(application)
                })
                DualPersistenceLayer(shouldAddToUpdateRealm: false).delete(planObjectToDelete) { _ in
                    if let index = self.planDataSource.firstIndex(where: { $0.planID == planID }) {
                        self.planDataSource.remove(at: index)
                    }

                    if self.planDataSource.count > 0 {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        self.shouldEditPlans = false
                        self.tableView.reloadData()
                    }
                }
            case .failure:
                self.showAlert(title: "Error Saving Grower", message: "Please try again.")
            }
        }
    }
}

// MARK: - RebateViewControllerDelegate

extension GrowerProfileViewController: RebateViewControllerDelegate {
    
    func rebateViewControllerDidSetDrawerPosition(_ rebateViewController: RebateViewController, position: PulleyPosition) {
        pulleyVC?.setDrawerPosition(position: position, animated: true)
        
    }
    
}

// MARK: - PlanDetailsViewControllerPulleyDelegate

extension GrowerProfileViewController: PlanDetailsViewControllerPulleyDelegate {
    
    func didTapDimmingView(_ planDetailsViewController: PlanDetailsViewController) {
        pulleyVC?.setDrawerPosition(position: .collapsed, animated: true)
    }
    
}

// MARK: - TableSectionHeaderViewDelegate

extension GrowerProfileViewController: TableSectionHeaderViewDelegate {
    
    func didTapPlusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton) {
        navigateToPlanDetails()
    }
    
    func didTapMinusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton) {
        shouldEditPlans = !shouldEditPlans
    }
    
}

// MARK: - GrowerDetailsViewControllerDelegate

extension GrowerProfileViewController: GrowerDetailsViewControllerDelegate {
    
    func didAddGrower(_ viewController: GrowerDetailsViewController, grower: Grower) {
        self.grower = grower
        configureNavBarView()
        let predicate = NSPredicate(format: "growerID = %@", grower.growerID)
        planDataSource = PersistenceLayer().fetch(PlanObject.self, predicate: predicate)?.map({ Plan(planObject: $0) }) ?? []
        
        tableView.reloadData()
    }
    
}

// MARK: - StyledButtonTableViewCellDelegate

extension GrowerProfileViewController: StyledButtonTableViewCellDelegate {
    
    func didTapButton(_ styledButtonTableViewCell: StyledButtonTableViewCell, sender: StyledButton) {
        editGrower(sender)
    }

}
