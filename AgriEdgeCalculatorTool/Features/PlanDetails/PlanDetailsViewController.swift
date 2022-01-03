//
//  PlanDetailsViewController.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/8/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Pulley
import MessageUI
import RMPickerViewController

class PlanDetailsViewController: BaseTableViewController, KeyboardDismissing, DataUploading, AnalyticsTracking, PDFCreation {

    // MARK: Outlets
    
    @IBOutlet private weak var dimmingView: UIView!
    
    // MARK: Public Properties
    
    var grower: Grower?
    
    weak var delegate: PlanDetailsViewControllerDelegate?
    weak var pulleyDelegate: PlanDetailsViewControllerPulleyDelegate?
    
    var currentPlan = Plan() {
        didSet {
            applications = currentPlan.applications
            seedApplications = currentPlan.seedApplications
            planNameCell.textFieldText = currentPlan.displayName
            enteredPlanName = currentPlan.displayName
            delegate?.didUpdateRebate(self, rebate: currentPlan.rebate)
            // NMTODO: This logic should check to see if the crop year is older than the current crop year as defined by a server side generated value
            // For now we have commented out logic so all plans are listed and none are read only
            // Another option would be to leave all plans as being fully enabled and have the user manage those.
            // isReadOnlyPlan = currentPlan.cropYear != "2020"
            updateTableViewData()
        }
    }
    
    override var primaryButton: (title: String, action: (() -> Void))? {
        return (title: "Save and Close", action: {
            self.logAnalytics(event: .saveGrower)
            self.dismissKeyboard()
            self.savePlan()
        })
    }
    
    var isEditingPlan: Bool = false
    
    // MARK: Private Properties
    
    private var isReadOnlyPlan = false
    private var hasEditedValues = false
    private var shouldUpdateTable = false
    private var sections = [Section]()
    private var createPlanStartTime = TimeInterval()
    private var enteredPlanName: String?
    private var enteredPlanPriority: Bool?
    private var applicationsIDToDelete = [String]()
    private var seedApplicationsIDToDelete = [String]()

    private var  isShowingKeyboard: Bool = false
    
    private var applications = [Application]()
    private var seedApplications = [SeedApplication]()
    
    private lazy var planNameHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "Plan Name"
        return headerView
    }()

    private lazy var planNameCell: LabeledTextFieldTableViewCell = {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = nil
        cell.textFieldPlaceholder = "give this plan a name"
        cell.isCellSeparatorHidden = true
        cell.delegate = self
        return cell
    }()
    
    private lazy var planConfidenceCell: PlanConfidenceTableViewCell = {
        let cell = PlanConfidenceTableViewCell.fromNib
        cell.planConfidence = currentPlan.planConfidence
        return cell
    }()
    
    private lazy var planPriorityCell: PlanPriorityTableViewCell = {
        let cell = PlanPriorityTableViewCell.fromNib
        cell.isPriority = currentPlan.isPriorityBool
        cell.delegate = self
        return cell
    }()
    
    private lazy var applicationsHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "Applications"
        headerView.isPlusButtonHidden = false
        headerView.isSeparatorViewHidden = true
        headerView.delegate = self
        return headerView
    }()
    
    private lazy var applicationsEmptyStateInfoCell: InfoLabelTableViewCell = {
        let cell = InfoLabelTableViewCell.fromNib
        cell.infoLabelText = "No applications yet.\nAdd an application to calculate a reward."
        return cell
    }()
    
    private lazy var addNewApplicationSectionHeader: StyledButtonTableSectionHeader = {
        let header = StyledButtonTableSectionHeader.fromNib
        header.buttonTitleLabelText = "New Application"
        header.buttonType = (.tertiary, .teal)
        header.delegate = self
        return header
    }()

    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTableViewData()
        logAnalytics(screen: .planDetails)
        dimmingView.isHidden = true
        isPrimaryButtonEnabled = false
        createPlanStartTime = NSDate().timeIntervalSince1970
        view.backgroundColor = SemanticCustomColor.tableBackground.uiColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isShowingKeyboard || isReadOnlyPlan { return }
        primaryButtonViewBottomConstraintConstant = RebateAttribute.allValues.isEnabled ? -84 + view.safeAreaInsets.bottom : -36 + view.safeAreaInsets.bottom
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.title = currentPlan.displayName.isEmpty ? "New Plan" : currentPlan.displayName
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePDF))
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(tapBack))
        backButton.image = UIImage(named: "leftChevron")
        backButton.imageInsets = UIEdgeInsets(top: 0.5, left: -7, bottom: 0, right: 0)
        parent?.navigationItem.leftBarButtonItem = backButton
        
        updateSaveApplicatonButtonState()
        
        if shouldUpdateTable {
            updateTableViewData()
            tableView.reloadData()
            shouldUpdateTable = false
        }
        
        if isReadOnlyPlan {
            logAnalytics(event: .viewExistingPlanReadOnly)
            isPrimaryButtonHidden = true
            planNameCell.isTextFieldEnabled = false
            // TODO: Make Application/SeedApplication elements read only
        }
    }
    
    @objc override open func adjustViewForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey]) as? UInt else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            isShowingKeyboard = false
            tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
            
            if primaryButton != nil {
                primaryButtonViewBottomConstraintConstant = RebateAttribute.allValues.isEnabled ? -84 + view.safeAreaInsets.bottom : -36 + view.safeAreaInsets.bottom
            }
            
        } else {
            isShowingKeyboard = true
            if primaryButton != nil {
                primaryButtonViewBottomConstraintConstant = -keyboardScreenEndFrame.height + view.safeAreaInsets.bottom
                tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: keyboardViewEndFrame.height + (primaryButtonViewBottomConstraintConstant ?? 0), right: 0)
            } else {
                tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: keyboardViewEndFrame.height - 24 + (primaryButtonViewBottomConstraintConstant ?? 0), right: 0)
            }
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset

        if primaryButton != nil {
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    // MARK: Actions
    
    @objc private func tapBack() {
        if hasEditedValues {
            let confirmAction = UIAlertAction(title: "Yes, leave", style: .destructive) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            showChoiceAlert(title: "Are you sure?", message: "Any unsaved changes will be lost.", alertActions: [confirmAction, cancelAction])
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction private func tapDimmingView(_ sender: UITapGestureRecognizer) {
        pulleyDelegate?.didTapDimmingView(self)
    }
        
    private func savePlan() {
        guard let planTitle = planNameCell.textFieldText, !planTitle.isEmpty else {
            showAlert(title: "Please enter a Plan Name")
            return
        }
        currentPlan.growerID = grower?.growerID ?? ""
        currentPlan.displayName = planTitle
        currentPlan.planConfidence = planConfidenceCell.planConfidence
        currentPlan.isPriority = planPriorityCell.isPriority ? 1 : 0
        if let enteredPlanName = self.enteredPlanName {
            currentPlan.displayName = enteredPlanName
        }
        let newPlanObject = PlanObject().project(from: currentPlan)
        
        applicationsIDToDelete.forEach { applicationID in
            let applicationPredicate = NSPredicate(format: "applicationID = %@", applicationID)
            if let foundApplication = PersistenceLayer().fetch(ApplicationObject.self, predicate: applicationPredicate)?.first {
                PersistenceLayer().delete(foundApplication)
            }
        }
        
        seedApplicationsIDToDelete.forEach { seedApplicationID in
            let seedApplicationPredicate = NSPredicate(format: "seedApplicationID = %@", seedApplicationID)
            if let foundSeedApplication = PersistenceLayer().fetch(SeedApplicationObject.self, predicate: seedApplicationPredicate)?.first {
                PersistenceLayer().delete(foundSeedApplication)
            }
        }
        
        // Check if we have isPriority set for this Plan and a different Plan already has it set, too
        let otherPriorityPlan = otherPriorityPlan(thisPlan: currentPlan)
        if let otherPriorityPlan = otherPriorityPlan {
            print("found otherPriorityPlan: \(otherPriorityPlan.displayName)")
            let otherPriorityPlanObject = PlanObject().project(from: otherPriorityPlan)
            otherPriorityPlanObject.isPriority = false //we can only have 1 priority Plan
            DualPersistenceLayer(shouldAddToUpdateRealm: true).save(otherPriorityPlanObject)
        }
        
        DualPersistenceLayer(shouldAddToUpdateRealm: true).save(newPlanObject) { result in
            switch result {
            case .success:
                OktaSessionManager.shared.refreshTokensIfNeeded {
                    self.uploadPlans()
                }
                self.navigationController?.popViewController(animated: true)
            case .failure:
                self.showAlert(title: "Error Saving Grower", message: "Please try again.")
            }
        }
        
        let planCreationTime = NSDate().timeIntervalSince1970 - createPlanStartTime
        logAnalytics(event: .savePlan, parameters: ["plan_creation_time": "\(planCreationTime)", "is_editing": String(self.isEditingPlan)])

    }
    
    /// Returns the other Plan for this Grower that has isPriority set to true, if any
    /// If this Plan has isPriority = false, then return nil
    private func otherPriorityPlan(thisPlan: Plan) -> Plan? {
        if thisPlan.isPriorityBool,
           let otherPriorityPlan = (grower?.plans ?? []).filter({ $0.isPriorityBool }).first,
           otherPriorityPlan.planID != thisPlan.planID {
            return otherPriorityPlan
        }
        return nil //catch all
    }
    
    // MARK: Share Functions
    
    @objc private func sharePDF() {
        guard !currentPlan.displayName.isEmpty else {
            showAlert(title: "Missing Plan", message: "Please save the Plan before sharing.")
            return
        }
        
        let shareEstimate = UIAlertAction(title: "Share as Estimate", style: .default) { _ in
            self.shareEstimate()
        }
        let shareCropPlan = UIAlertAction(title: "Share as Crop Plan", style: .default) { _ in
            self.shareCropPlan()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         showChoiceActionSheet(alertActions: [shareEstimate, shareCropPlan, cancel], barButtonItem: parent?.navigationItem.rightBarButtonItem)
    }
    
    private func shareEstimate() {
        logAnalytics(event: .sharePDFEstimate)
        sharePDFByShareFunction(documentType: .estimate)
    }
    
    private func shareCropPlan() {
        logAnalytics(event: .sharePDFCropPlan)
        sharePDFByShareFunction(documentType: .cropPlan)
    }
    
    private func sharePDFByShareFunction(documentType: DocumentType) {
        guard let dataURL = generatePDF(with: grower, from: currentPlan, documentType: documentType)  else { return }
        
        let subject = "\(documentType.documentName) for \(grower?.fullName ?? "Grower")"
        let emailItem = EmailProvider(subject: subject, message: subject)

        let activityViewController = UIActivityViewController(activityItems: [emailItem, dataURL], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            try? FileManager.default.removeItem(at: dataURL)
        }

        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.barButtonItem = parent?.navigationItem.rightBarButtonItem
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    private func navigateToApplicationDetails(sender: Any?) {
        dismissKeyboard()
        if let name = enteredPlanName {
            currentPlan.displayName = name
        }
        if let planPriority = enteredPlanPriority {
            currentPlan.isPriority = planPriority ? 1 : 0
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ApplicationDetailsSegue", sender: sender)
        }
    }
    
    private func navigateToSeedApplicationDetails(sender: Any?) {
        dismissKeyboard()
        if let name = enteredPlanName {
            currentPlan.displayName = name
        }
        if let planPriority = enteredPlanPriority {
            currentPlan.isPriority = planPriority ? 1 : 0
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "SeedApplicationDetailsSegue", sender: sender)
        }
    }
    
    @IBAction private func unwindToPlanDetailsViewController(_ segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let applicationDetailsNavVC = segue.destination as? UINavigationController,
            let applicationDetailsVC = applicationDetailsNavVC.topViewController as? ApplicationDetailsViewController {
            
            applicationDetailsVC.grower = grower
            applicationDetailsVC.delegate = self
            if let application = sender as? Application {
                let selectedApplicationID = application.applicationID
                applicationDetailsVC.editApplication = applications.first(where: { $0.applicationID == selectedApplicationID })
            } else if let header = sender as? TableSectionHeaderView {
                let crops = grower?.crops?.compactMap({ $0.cropID.cropNameFromID() })
                let selectedCrop = crops?.filter({ header.titleLabelText?.contains($0) ?? false }) ?? []
                applicationDetailsVC.specificCropsSelected = selectedCrop
            }
        } else if let seedApplicationDetailsNavVC = segue.destination as? UINavigationController,
            let seedApplicationDetailsVC = seedApplicationDetailsNavVC.topViewController as? SeedApplicationDetailsViewController {
            
            seedApplicationDetailsVC.grower = grower
            seedApplicationDetailsVC.delegate = self
            if let seedApplication = sender as? SeedApplication {
                let selectedSeedApplicationID = seedApplication.seedApplicationID
                seedApplicationDetailsVC.editSeedApplication = seedApplications.first(where: { $0.seedApplicationID == selectedSeedApplicationID })
            } else if let header = sender as? TableSectionHeaderView {
                let crops = grower?.crops?.compactMap({ $0.cropID.cropNameFromID() })
                let selectedCrop = crops?.filter({ header.titleLabelText?.contains($0) ?? false }) ?? []
                seedApplicationDetailsVC.specificCropsSelected = selectedCrop
            }
        }
    }
    
    // MARK: Helpers

    private func updateTableViewData() {
        var newSections = [Section]()
        // Add PlanConfidence
        let planConfidenceSection = Section(sectionType: .planProperties, rows: [.planName, .planPriority, .planConfidence])
        newSections.append(planConfidenceSection)
        // Add Applications/SeedApplications
        let applicationUniqueCropIDs = Set(applications.compactMap({ $0.cropID }))
        let seedApplicationUniqueCropIDs = Set(seedApplications.compactMap({ $0.cropID }))
        let uniqueCropIDs = applicationUniqueCropIDs.union(seedApplicationUniqueCropIDs)
        let sortedUniqueCropIDs = uniqueCropIDs.sorted(by: { ($0.cropNameFromID() ?? "") < ($1.cropNameFromID() ?? "") })
        sortedUniqueCropIDs.forEach({ (cropID: String) in
            // 1 Section for each unique crop
            let seedApplicationRows = seedApplications.filter({ $0.cropID == cropID }).map({
                return Row.seedApplication($0)
            })
            let applicationRows = applications.filter({ $0.cropID == cropID }).map({
                return Row.application($0)
            })
            let cropApplicationsSection = Section(sectionType: .applications, sectionName: "\(cropID.cropNameFromID() ?? "") Applications", rows: seedApplicationRows + applicationRows)
            newSections.append(cropApplicationsSection)
        })
        // Add a new Application section
        newSections.append(Section(sectionType: .addNewApplication, sectionName: nil, rows: []))
        // Should we add Save Plan button section?
        if isReadOnlyPlan {
            newSections.append(Section(sectionType: .savePlan, rows: []))
        }
        
        sections = newSections
    }
    
    private func updateSaveApplicatonButtonState() {
        if let enteredPlanName = self.enteredPlanName,
         !enteredPlanName.isEmpty &&
         (applications.count > 0 || seedApplications.count > 0) {
            isPrimaryButtonEnabled = true
        } else {
            isPrimaryButtonEnabled = false
        }
    }

    private func handlePlanConfidenceSelection() {
        if let pickerController = RMPickerViewController(style: .white, title: "Choose Plan Confidence", message: nil, select: RMAction(title: "Select", style: .done, andHandler: { pickerController in
            let selectedRow = pickerController.contentView.selectedRow(inComponent: 0)
            if let name = self.enteredPlanName {
                self.currentPlan.displayName = name
            }
            self.currentPlan.planConfidence = PlanConfidence(rawValue: selectedRow) ?? .level1
            self.planConfidenceCell.planConfidence = self.currentPlan.planConfidence
        }), andCancel: RMAction(title: "Cancel", style: .cancel, andHandler: { _ in
            // nothing to do for Cancel
        })) {
            pickerController.picker.dataSource = self
            pickerController.picker.delegate = self
            pickerController.picker.selectRow(currentPlan.planConfidence.rawValue, inComponent: 0, animated: false)
            pickerController.disableBouncingEffects = true
            present(pickerController, animated: true)
        }
    }
}

// MARK: - UIPickerDatasource
extension PlanDetailsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        PlanConfidence.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let planConfidence = PlanConfidence.allCases[row]
        return pickerRowView(planConfidence: planConfidence)
    }
    
    private func pickerRowView(planConfidence: PlanConfidence) -> UIView {
        let pickerRowView = UIView(frame: CGRect.zero)
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = planConfidence.title
        label.textColor = UIColor.black
        pickerRowView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: pickerRowView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: pickerRowView.centerYAnchor).isActive = true
        let colorView = UIView(frame: CGRect.zero)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        pickerRowView.addSubview(colorView)
        colorView.backgroundColor = planConfidence.color
        colorView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        colorView.layer.cornerRadius = 7
        colorView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -4).isActive = true
        colorView.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        return pickerRowView
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension PlanDetailsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        switch row {
        case .planName:
            let cell = planNameCell
            if let enteredPlanName = enteredPlanName {
                cell.textFieldText = enteredPlanName
            }
            return cell
        case .planConfidence:
            let cell = planConfidenceCell
            cell.planConfidence = currentPlan.planConfidence
            return cell
        case .planPriority:
            let cell = planPriorityCell
            if let enteredPlanPriority = enteredPlanPriority {
                cell.isPriority = enteredPlanPriority
            } else {
                cell.isPriority = currentPlan.isPriorityBool
            }
            return cell
        case .application(let application):
            let applicationCell = LabeledTableViewCell.fromNib
            let isLastRowInSection = (indexPath.row + 1) == section.rows.count
            applicationCell.configure(titleLabelText: application.productID.productNameFromID() ?? "Missing Plan Name",
                                      subtitleLabelText: "\(application.appliedRate) \(application.appliedUoM.rateDisplayName)",
                accessoryLabelText: "\(application.appliedAcreage) acres",
                isSeparatorHidden: isLastRowInSection)
            return applicationCell
        case .seedApplication(let seedApplication):
            let seedApplicationCell = LabeledTableViewCell.fromNib
            let isLastRowInSection = (indexPath.row + 1) == section.rows.count
            seedApplicationCell.configure(titleLabelText: seedApplication.seedID.seedNameFromID() ?? "Missing Plan Name",
                                      subtitleLabelText: "\(seedApplication.appliedRate) \(seedApplication.appliedUoM.rateDisplayName)",
                accessoryLabelText: "\(seedApplication.appliedAcreage) acres",
                isSeparatorHidden: isLastRowInSection)
            return seedApplicationCell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionObject = sections[section]
        switch sectionObject.sectionType {
        case .planProperties:
            return planNameHeaderView
        case .applications:
            let headerView = TableSectionHeaderView.fromNib
            headerView.titleLabelText = sectionObject.sectionName
            headerView.isPlusButtonHidden = false
            headerView.delegate = self
            return headerView
        case .addNewApplication:
            return addNewApplicationSectionHeader
        case .savePlan:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let row = section.rows[indexPath.row]
        switch section.sectionType {
        case .planProperties:
            switch row {
            case .planConfidence:
                handlePlanConfidenceSelection()
            default: break
            }
        case .applications:
            switch row {
            case .application(let application):
                logAnalytics(event: .viewExistingApplication)
                navigateToApplicationDetails(sender: application)
            case .seedApplication(let seedApplication):
                logAnalytics(event: .viewExistingSeedApplication)
                navigateToSeedApplicationDetails(sender: seedApplication)
            default: break
            }
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionObject = sections[section]
        switch sectionObject.sectionType {
        case .planProperties: return 40
        case .addNewApplication: return 72
        default: return 64
        }
    }
    
    enum TableViewSection {
        case planProperties
        case applications
        case addNewApplication
        case savePlan
    }
    
    struct Section {
        var sectionType: TableViewSection
        var sectionName: String?
        var rows: [Row]
    }
    
    enum Row {
        case planName
        case planConfidence
        case planPriority
        case application(Application)
        case seedApplication(SeedApplication)
    }
}

// MARK: - ApplicationDetailsViewControllerDelegate

extension PlanDetailsViewController: ApplicationDetailsViewControllerDelegate {
    
    func applicationDetailsDidSaveApplications(_ applicationDetailsViewController: ApplicationDetailsViewController, applications: [Application]) {
        hasEditedValues = true
        shouldUpdateTable = true
        
        self.applications.removeAll(where: { application in
            applications.contains(where: { $0.applicationID == application.applicationID })
        })
        self.applications.append(contentsOf: applications)
        
        currentPlan.applications = self.applications

        guard let grower = grower else { return }
        let rebate = RebateCalculator().calculateRebate(from: currentPlan, for: grower)
        currentPlan.rebate = rebate
        delegate?.didUpdateRebate(self, rebate: rebate)
        updateSaveApplicatonButtonState()
    }
    
    func applicationDetailsDidDeleteApplication(_ applicationDetailsViewController: ApplicationDetailsViewController, application: Application) {
        hasEditedValues = true
        shouldUpdateTable = true
        
        self.applications.removeAll(where: { $0.applicationID == application.applicationID })
        currentPlan.applications.removeAll(where: { $0.applicationID == application.applicationID })
        applicationsIDToDelete.append(application.applicationID)
        
        guard let grower = grower else { return }
        let rebate = RebateCalculator().calculateRebate(from: currentPlan, for: grower)
        currentPlan.rebate = rebate
        delegate?.didUpdateRebate(self, rebate: rebate)
        updateSaveApplicatonButtonState()
    }
    
}

// MARK: - SeedApplicationDetailsViewControllerDelegate

extension PlanDetailsViewController: SeedApplicationDetailsViewControllerDelegate {
    
    func seedApplicationDetailsDidSaveSeedApplications(_ seedApplicationDetailsViewController: SeedApplicationDetailsViewController, seedApplications: [SeedApplication]) {
        hasEditedValues = true
        shouldUpdateTable = true
        
        self.seedApplications.removeAll(where: { seedApplication in
            seedApplications.contains(where: { $0.seedApplicationID == seedApplication.seedApplicationID })
        })
        self.seedApplications.append(contentsOf: seedApplications)
        
        currentPlan.seedApplications = self.seedApplications

        guard let grower = grower else { return }
        let rebate = RebateCalculator().calculateRebate(from: currentPlan, for: grower)
        currentPlan.rebate = rebate
        delegate?.didUpdateRebate(self, rebate: rebate)
        updateSaveApplicatonButtonState()
    }
    
    func seedApplicationDetailsDidDeleteSeedApplication(_ seedApplicationDetailsViewController: SeedApplicationDetailsViewController, seedApplication: SeedApplication) {
        hasEditedValues = true
        shouldUpdateTable = true
        
        self.seedApplications.removeAll(where: { $0.seedApplicationID == seedApplication.seedApplicationID })
        currentPlan.seedApplications.removeAll(where: { $0.seedApplicationID == seedApplication.seedApplicationID })
        seedApplicationsIDToDelete.append(seedApplication.seedApplicationID)
        
        guard let grower = grower else { return }
        let rebate = RebateCalculator().calculateRebate(from: currentPlan, for: grower)
        currentPlan.rebate = rebate
        delegate?.didUpdateRebate(self, rebate: rebate)
        updateSaveApplicatonButtonState()
    }
    
}

// MARK: - LabeledTextFieldTableViewCellDelegate

extension PlanDetailsViewController: LabeledTextFieldTableViewCellDelegate {
    
    func textFieldShouldChangeCharacters(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if labeledTextFieldTableViewCell == planNameCell,
         let text = textField.text,
         let textRange = Range(range, in: text) {
            let textFieldText = text.replacingCharacters(in: textRange, with: string)
            enteredPlanName = textFieldText
            updateSaveApplicatonButtonState()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) {
        hasEditedValues = true
        addKeyboardDismissGestureRecognizer()
    }
    
    func textFieldDidEndEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) {
        removeKeyboardDismissGestureRecognizer()
    }
    
}

// MARK: - TableSectionHeaderViewDelegate

extension PlanDetailsViewController: TableSectionHeaderViewDelegate {
    
    func didTapPlusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton) {
        newApplicationAction(sender: tableSectionHeaderView)
    }
    
    private func newApplicationAction(sender: Any?) {
        let newApplication = UIAlertAction(title: "New CP Application", style: .default) { _ in
            self.logAnalytics(event: .createNewApplication)
            self.navigateToApplicationDetails(sender: sender)
        }
        let newSeedApplication = UIAlertAction(title: "New Seed Application", style: .default) { _ in
            self.logAnalytics(event: .createNewSeedApplication)
            self.navigateToSeedApplicationDetails(sender: sender)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        showChoiceAlert(alertActions: [newApplication, newSeedApplication, cancel])
    }
}

// MARK: - BorderedButtonTableViewCellDelegate

extension PlanDetailsViewController: StyledButtonTableSectionHeaderDelegate {
    func didTapStyledButton(_ styledButtonTableSectionHeader: StyledButtonTableSectionHeader, sender: StyledButton) {
        newApplicationAction(sender: sender)
    }
}

// MARK: - TableSectionHeaderViewDelegate

extension PlanDetailsViewController: RebateViewControllerPulleyDelegate {
    
    func rebateViewControllerDidChangeDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        let min = drawer.collapsedDrawerHeight(bottomSafeArea: bottomSafeArea)
        let max = drawer.partialRevealDrawerHeight(bottomSafeArea: bottomSafeArea)
        let range = max - min
        let startingPercentage = distance - min
        var percentage = (startingPercentage * 100) / range
        
        if distance > min {
            self.view.bringSubviewToFront(dimmingView)
            dimmingView.isHidden = false
            if percentage > 100 { percentage = 100 }
            dimmingView.alpha = (percentage / 100) / 4
        } else if distance <= min {
            dimmingView.isHidden = true
            dimmingView.alpha = (percentage / 100) / 4
        }
    }
    
}

// MARK: - PlanDetailsViewControllerDelegate

protocol PlanDetailsViewControllerDelegate: AnyObject {
    func didUpdateRebate(_ planDetailsViewController: PlanDetailsViewController, rebate: Rebate?)
}

// MARK: - PlanDetailsViewControllerPulleyDelegate

protocol PlanDetailsViewControllerPulleyDelegate: AnyObject {
    func didTapDimmingView(_ planDetailsViewController: PlanDetailsViewController)
}

// MARK: - PlanPriorityTableViewCellDelegate

extension PlanDetailsViewController: PlanPriorityTableViewCellDelegate {
    func didChangePlanPriority(isPriority: Bool) {
        enteredPlanPriority = isPriority
        var plan = currentPlan
        plan.isPriority = isPriority ? 1 : 0
        if isPriority,
           let otherPriorityPlan = otherPriorityPlan(thisPlan: plan) {
            let displayMessage = "If you Save this change, \(otherPriorityPlan.displayName) will not be a Priority Plan anymore."
            showAlert(title: "Note", message: displayMessage)
        }
    }
}
