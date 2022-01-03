//
//  GrowerDetailsViewController.swift
//  AgriEdgeCalculatorTool
//
//  Created by lloyd on 6/13/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

class GrowerDetailsViewController: BaseTableViewController, KeyboardDismissing, DataUploading, AnalyticsTracking {
    
    // MARK: Public Properties

    weak var delegate: GrowerDetailsViewControllerDelegate?
    var grower = Grower()
    
    var isEditingGrower = false {
        didSet {
            if isEditingGrower {
                setupGrowerPageTextfieldText()
            }
        }
    }
    
    private var proposedZone: Zone?
    
    override var primaryButton: (title: String, action: (() -> Void))? {
        return (title: "Save and Close", action: {
            self.logAnalytics(event: .saveGrower)
            self.dismissKeyboard()
            self.saveGrower()
        })
    }

    // MARK: Private Properties
    
    private var zones = [Zone]()
    private var staticCropsList = [Crop]()
    private var cropDataSource = [PlantedCrop]() {
        didSet {
            cropHeaderView.isMinusButtonHidden = (cropDataSource.count > 0) ? false : true
        }
    }
    private var shouldEditCrops: Bool = false {
        didSet {
            tableView.setEditing(shouldEditCrops ? true : false, animated: true)
        }
    }
    private var plantedCropsToDelete = [PlantedCrop]()
    private var plantedCropsEdited = [PlantedCrop]()
    private var firstResponderCropCell: LabeledTextFieldAccessoryTableViewCell?
        
    // MARK: Table View Cells
    
    // MARK: Grower Profile Cells
    private lazy var farmNameCell: LabeledTextFieldTableViewCell = {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "Farm Name"
        cell.textFieldPlaceholder = "farm name"
        cell.delegate = self
        return cell
    }()

    private lazy var zoneCell: LabeledTextFieldTableViewCell = {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "AgriEdge Zone"
        cell.textFieldPlaceholder = "zone"
        cell.shouldShowArrowAccessoryView = true
        cell.isCellSeparatorHidden = true
        cell.delegate = self
        return cell
    }()
    
    // MARK: Additional Info Cells
    private lazy var firstNameCell: LabeledTextFieldTableViewCell = {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "First Name (optional)"
        cell.textFieldPlaceholder = "first name"
        cell.delegate = self
        return cell
    }()
    
    private lazy var lastNameCell: LabeledTextFieldTableViewCell = {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "Last Name (optional)"
        cell.textFieldPlaceholder = "last name"
        cell.delegate = self
        return cell
    }()
    
    private lazy var emailCell: LabeledTextFieldTableViewCell = {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "Email (optional)"
        cell.textFieldPlaceholder = "email"
        cell.textFieldContentType = .emailAddress
        cell.textFieldKeyboardType = .emailAddress
        cell.delegate = self
        return cell
    }()
    
    private lazy var phoneNumberCell: LabeledTextFieldTableViewCell = {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "Phone (optional)"
        cell.textFieldPlaceholder = "(123) 456-7890"
        cell.textFieldContentType = .telephoneNumber
        cell.textFieldKeyboardType = .phonePad
        cell.isCellSeparatorHidden = true
        cell.delegate = self
        return cell
    }()
    
    // MARK: Crop Cells
    private var cropHeaderView: TableSectionHeaderView {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "My Crops"
        headerView.isPlusButtonHidden = (!grower.zoneID.isEmpty) ? false : true
        headerView.isMinusButtonHidden = (!cropDataSource.isEmpty) ? false : true
        headerView.delegate = self
        return headerView
    }
    
    private var cropEmptyStateInfoCell: InfoLabelTableViewCell {
        let cell = InfoLabelTableViewCell.fromNib
        cell.infoLabelText = (!grower.zoneID.isEmpty) ? "No crops added." : "Please select a zone first."
        return cell
    }
        
    // MARK: Cell Sources
    private lazy var nameSectionCellSource: [LabeledTextFieldTableViewCell] = {
        return [self.farmNameCell, self.zoneCell]
    }()
    
    private lazy var infoSectionCellSource: [LabeledTextFieldTableViewCell] = {
        return [self.firstNameCell, self.lastNameCell, self.emailCell, self.phoneNumberCell]
    }()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LabeledTextFieldAccessoryTableViewCell.nib, forCellReuseIdentifier: LabeledTextFieldAccessoryTableViewCell.nibName)
        tableView.register(TableSectionHeaderView.nib, forCellReuseIdentifier: TableSectionHeaderView.nibName)
        view.backgroundColor = SemanticCustomColor.tableBackground.uiColor

        logAnalytics(screen: .growerDetails)
        fetchZones()
        fetchCrops()
        updateSaveButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let firstResponderCropCell = firstResponderCropCell {
            firstResponderCropCell.shouldTextFieldBecomeFirstResponder = true
            self.firstResponderCropCell = nil
        }
        checkForZoneChange()
    }
    
    // MARK: Actions
        
    @IBAction private func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func deleteGrower(_ sender: Any) {
        switch grower.source {
        case .salesforceImport:
            let okButton = UIAlertAction(title: "OK", style: .cancel)
            showChoiceAlert(title: "This is a Salesforce Grower, and cannot be deleted.", message: nil, alertActions: [okButton], completion: nil)
        case .userCreated:
            let confirmDelete = UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.logAnalytics(event: .deleteGrower)
                self.deleteGrower()
            }
            let cancelDelete = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            showChoiceAlert(title: "Are you sure you want to delete this grower?", message: nil, alertActions: [confirmDelete, cancelDelete], completion: nil)
        }
    }
    
    // MARK: Navigation
    
    private func navigateToZoneList() {
        logAnalytics(screen: .zonesList)
        DispatchQueue.main.async {
            if let zones = PersistenceLayer().fetch(UserObject.self)?.first?.allowedZones {
                self.zones = self.zones.filter({ zones.contains($0.zoneID) }).sorted(by: { $0.displayName < $1.displayName })
            }

            self.pushSearchViewController(title: "AgriEdge Zone", dataSource: self.zones)
        }
    }
    
    private func navigateToCropList() {
        logAnalytics(screen: .cropsList)
        DispatchQueue.main.async {
            self.dismissKeyboard()
            let currentSelectedCrops = self.cropDataSource.map({ $0.cropID })
            let filteredCropList = self.staticCropsList.filter({ !currentSelectedCrops.contains($0.cropID) && $0.zonePrice.keys.contains(self.grower.zoneID) })

            self.pushSearchViewController(title: "Crop List", dataSource: filteredCropList)
        }
    }
    
    // MARK: Save Grower
    
    private func saveGrower() {
        grower.crops = cropDataSource
        plantedCropsToDelete.forEach { plantedCrop in
            let predicate = NSPredicate(format: "plantedCropID = %@", plantedCrop.plantedCropID)
            if let plantedCropFound = PersistenceLayer().fetch(PlantedCropObject.self, predicate: predicate)?.first {
                PersistenceLayer().delete(plantedCropFound)
            }
        }
        let newGrowerObject = GrowerObject().project(from: grower)
        var plansToUpdate = [PlanObject]()
        let predicate = NSPredicate(format: "growerID = %@", newGrowerObject.growerID)
        if let planDataSource = PersistenceLayer().fetch(PlanObject.self, predicate: predicate) {
            planDataSource.forEach({ planObject in
                var markForReadOnly = false
                planObject.applications.forEach({ applicationObject in
                    if self.plantedCropsToDelete.contains(where: { $0.cropID == applicationObject.cropID }) {
                        markForReadOnly = true
                    } else if self.plantedCropsEdited.contains(where: { plantedCrop in
                        if plantedCrop.cropID == applicationObject.cropID,
                            plantedCrop.plantedAcreage < (Double(applicationObject.appliedAcreage) ?? 0.0) {
                            return true
                        } else {
                            return false
                        }
                    }) {
                        markForReadOnly = true
                    }
                })
                if markForReadOnly {
                    plansToUpdate.append(planObject)
                }
            })
        }
        if isEditingGrower && !plansToUpdate.isEmpty {
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                plansToUpdate.forEach({ planObject in
                    let predicate = NSPredicate(format: "planID = %@", planObject.planID)
                    if let planFound = PersistenceLayer().fetch(PlanObject.self, predicate: predicate)?.first {
                        PersistenceLayer().update(planFound, updates: { $0.cropYear = "2020-RO" })
                    }
                })
                self.plantedCropsToDelete.forEach({ plantedCrop in
                    let predicate = NSPredicate(format: "plantedCropID = %@", plantedCrop.plantedCropID)
                    if let plantedCropObjects = PersistenceLayer().fetch(PlantedCropObject.self, predicate: predicate) {
                        plantedCropObjects.forEach({ PersistenceLayer().delete($0) })
                    }
                })
                let growerIDPredicate = NSPredicate(format: "growerID = %@", newGrowerObject.growerID)
                
                var updatedPlans = [PlanObject]()
                if let planObjectsFound = PersistenceLayer().fetch(PlanObject.self, predicate: growerIDPredicate) {
                    planObjectsFound.forEach({ newPlanObject in
                        if let rebateID = newPlanObject.rebate?.rebateID {
                            let predicate = NSPredicate(format: "rebateID = %@", rebateID)
                            if let rebateToDelete = PersistenceLayer().fetch(RebateObject.self, predicate: predicate)?.first {
                                PersistenceLayer().delete(rebateToDelete)
                            }
                        }
                        PersistenceLayer().update(newPlanObject, updates: { planToUpdate in
                            let planObject = Plan(planObject: newPlanObject)
                            let growerObject = Grower(growerObject: newGrowerObject)
                            let updatedRebate = RebateCalculator().calculateRebate(from: planObject, for: growerObject)
                            planToUpdate.rebate = RebateObject().project(from: updatedRebate)
                        })
                        
                        updatedPlans.append(newPlanObject)
                    })
                }
                
                PersistenceLayer().update(newGrowerObject, updates: { growerToUpdate in
                    growerToUpdate.plans.removeAll()
                    
                    updatedPlans.forEach({
                        growerToUpdate.plans.append($0)
                    })
                })

                DualPersistenceLayer(shouldAddToUpdateRealm: true).save(newGrowerObject) { result in
                    switch result {
                    case .success:
                        OktaSessionManager.shared.refreshTokensIfNeeded {
                            self.uploadGrowers()
                        }
                        let newGrower = Grower(growerObject: newGrowerObject)
                        self.delegate?.didAddGrower(self, grower: newGrower)
                        self.dismiss(animated: true, completion: nil)
                    case .failure:
                        self.showAlert(title: "Error Saving Grower", message: "Please try again.")
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            showChoiceAlert(title: "\(plansToUpdate.count) \(plansToUpdate.count > 1 ? "Plans" : "Plan") Affected", message: "Making this edit will cause the affected plans to be frozen and calculations on the affected plans will not be updated to reflect these edits. Would you like to continue?", alertActions: [confirmAction, cancelAction], completion: nil)
        } else {
            // Recalculate Rebates for each Plan
            // Do it once for default Realm
            PersistenceLayer().save(newGrowerObject) { result in
                switch result {
                case .success:
                    let predicate = NSPredicate(format: "growerID = %@", newGrowerObject.growerID)
                    if let planObjectsFound = PersistenceLayer().fetch(PlanObject.self, predicate: predicate) {
                        planObjectsFound.forEach({ newPlanObject in
                            if let rebateID = newPlanObject.rebate?.rebateID {
                                let predicate = NSPredicate(format: "rebateID = %@", rebateID)
                                if let rebateToDelete = PersistenceLayer().fetch(RebateObject.self, predicate: predicate)?.first {
                                    rebateToDelete.realm?.delete(rebateToDelete)
                                }
                            }
                            let plan = Plan(planObject: newPlanObject)
                            let updatedRebate = RebateCalculator().calculateRebate(from: plan, for: self.grower)
                            let updatedRebateObject = RebateObject().project(from: updatedRebate)
                            newPlanObject.rebate = updatedRebateObject
                        })
                    }
                case .failure:
                    self.showAlert(title: "Error Saving Grower", message: "Please try again.")
                }
            }
            // Do it again for update Realm - This previously tried to use DualPersistenceLayer to do
            // both realms at once, but it was not working completely (e.g. new Rebate object wasn't saved to Realm)
            PersistenceLayer(configuration: .update).create(newGrowerObject) { result in
                switch result {
                case .success:
                    let newGrower = Grower(growerObject: newGrowerObject)
                    let predicate = NSPredicate(format: "growerID = %@", newGrowerObject.growerID)
                    if let planObjectsFound = PersistenceLayer(configuration: .update).fetch(PlanObject.self, predicate: predicate) {
                        planObjectsFound.forEach({ newPlanObject in
                            if let rebateID = newPlanObject.rebate?.rebateID {
                                let predicate = NSPredicate(format: "rebateID = %@", rebateID)
                                if let rebateToDelete = PersistenceLayer(configuration: .update).fetch(RebateObject.self, predicate: predicate)?.first {
                                    rebateToDelete.realm?.delete(rebateToDelete)
                                }
                            }
                            let plan = Plan(planObject: newPlanObject)
                            let updatedRebate = RebateCalculator().calculateRebate(from: plan, for: self.grower)
                            let updatedRebateObject = RebateObject().project(from: updatedRebate)
                            newPlanObject.rebate = updatedRebateObject
                        })
                    }
                    self.delegate?.didAddGrower(self, grower: newGrower)
                    self.uploadGrowers()
                    self.dismiss(animated: true, completion: nil)
                case .failure:
                    self.showAlert(title: "Error Saving Grower", message: "Please try again.")
                }
            }
        }
    }
    
    // MARK: Delete Grower
    
    private func deleteGrower() {
        let growerToDelete = GrowerObject().project(from: grower)
        growerToDelete.shouldDelete = true
        DualPersistenceLayer(shouldAddToUpdateRealm: true).save(growerToDelete) { result in
            switch result {
            case .success:
                OktaSessionManager.shared.refreshTokensIfNeeded {
                    self.deleteGrowers()
                }
                
                let plantedCropObjectsToDelete = self.grower.crops?.map({ $0.plantedCropID })
                plantedCropObjectsToDelete?.forEach({ plantedCropID in
                    let predicate = NSPredicate(format: "plantedCropID = %@", plantedCropID)
                    guard let plantedCrop = PersistenceLayer().fetch(PlantedCropObject.self, predicate: predicate)?.first else { return }
                    PersistenceLayer().delete(plantedCrop)
                })
                
                let predicate = NSPredicate(format: "growerID = %@", growerToDelete.growerID)
                if let planDataSource = PersistenceLayer().fetch(PlanObject.self, predicate: predicate) {
                    planDataSource.forEach({ planObject in
                        PersistenceLayer().update(planObject, updates: { $0.shouldDelete = true })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            let newPlan = Plan(planObject: planObject)
                            let newRealmPlan = PlanObject().project(from: newPlan)
                            PersistenceLayer(configuration: .update).save(newRealmPlan) { result in
                                switch result {
                                case .success:
                                    if let rebateToDelete = planObject.rebate {
                                        PersistenceLayer().delete(rebateToDelete)
                                    }
                                    planObject.applications.forEach({ application in
                                        PersistenceLayer().delete(application)
                                    })
                                    PersistenceLayer().delete(planObject)
                                case .failure:
                                    self.showAlert(title: "Error deleting Grower", message: "Please try again.")
                                }
                            }
                        }
                    })
                }
                
                PersistenceLayer().delete(growerToDelete) { _ in
                    self.performSegue(withIdentifier: "UnwindToGrowerListSegue", sender: self)
                }
            case .failure:
                self.showAlert(title: "Error deleting Grower", message: "Please try again.")
            }
        }
    }
    
    // MARK: Fetch Zones and Crops
    
    private func fetchZones() {
        guard let zoneObjects = DualPersistenceLayer().fetch(ZoneObject.self) else {
            log(error: "error fetching zones realm")
            return
        }
        
        zones = zoneObjects.map({
            (zoneObject: ZoneObject) -> Zone in
            return Zone(zoneObject: zoneObject)
        })
    }
    
    private func fetchCrops() {
        guard let cropObjects = PersistenceLayer().fetch(CropObject.self) else {
            log(error: "error fetching crops realm")
            return
        }
        
        self.staticCropsList = cropObjects.map({
            (cropObject: CropObject) -> Crop in
            return Crop(cropObject: cropObject)
        })
    }
    
    // MARK: Helpers
    
    private func checkForZoneChange() {
        if let newlyProposedZone = proposedZone {
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
                self.zoneCell.textFieldText = newlyProposedZone.displayName
                self.grower.zoneID = newlyProposedZone.zoneID
                var invalidCrops = [PlantedCrop]()
                self.cropDataSource.forEach { plantedCrop in
                    let predicate = NSPredicate(format: "cropID = %@", plantedCrop.cropID)
                    if let cropObjectToTest = PersistenceLayer().fetch(CropObject.self, predicate: predicate)?.first {
                        let cropToTest = Crop(cropObject: cropObjectToTest)
                        if !cropToTest.zonePrice.keys.contains(newlyProposedZone.zoneID) {
                            invalidCrops.append(plantedCrop)
                        }
                    }
                }
                self.deleteCrops(for: invalidCrops)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            showChoiceAlert(title: "Zone change warning", message: "Making this edit will cause Crops not existant in this zone to be removed. Would you like to continue?", alertActions: [confirmAction, cancelAction], completion: nil)
            proposedZone = nil
        }
    }
    
    private func updateSaveButtonState() {
        guard !grower.farmName.isEmpty,
            !grower.zoneID.isEmpty,
            !cropDataSource.isEmpty else {
                isPrimaryButtonEnabled = false
                return
        }

        let hasAcreageForAllPlantedCrops = cropDataSource.map({ $0.plantedAcreage }).filter({ $0 == 0 }).isEmpty
        if hasAcreageForAllPlantedCrops {
            isPrimaryButtonEnabled = true
        } else {
            isPrimaryButtonEnabled = false
        }
    }
    
    private func setupGrowerPageTextfieldText() {
        title = grower.fullName
        firstNameCell.textFieldText = grower.firstName
        lastNameCell.textFieldText = grower.lastName
        farmNameCell.textFieldText = grower.farmName
        cropDataSource = grower.crops ?? []
        phoneNumberCell.textFieldText = grower.phoneNumber
        zoneCell.textFieldText = grower.zoneID.zoneDisplayNameFromID()
        emailCell.textFieldText = grower.email
    }
    
    private func deleteCropAtIndexPath(indexPath: IndexPath) {
        let plantedCropID = cropDataSource[indexPath.row].plantedCropID
        if plantedCropsEdited.contains(where: { $0.plantedCropID == plantedCropID }) {
            plantedCropsEdited.removeAll(where: { $0.plantedCropID == plantedCropID })
        }
        plantedCropsToDelete.append(cropDataSource[indexPath.row])
        cropDataSource.remove(at: indexPath.row)
        if cropDataSource.count > 0 {
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else {
            shouldEditCrops = false
            tableView.reloadData()
        }
        updateSaveButtonState()
    }
    
    private func deleteCrops(for cropsToDelete: [PlantedCrop]) {
        var indexPathsToDelete = [IndexPath]()
        cropsToDelete.forEach { plantedCrop in
            if let plantedCropIndex = cropDataSource.firstIndex(where: { $0.plantedCropID == plantedCrop.plantedCropID }) {
                if plantedCropsEdited.contains(where: { $0.plantedCropID == plantedCrop.plantedCropID }) {
                    plantedCropsEdited.removeAll(where: { $0.plantedCropID == plantedCrop.plantedCropID })
                }
                plantedCropsToDelete.append(cropDataSource[plantedCropIndex])
                cropDataSource.remove(at: plantedCropIndex)
                indexPathsToDelete.append(IndexPath(row: plantedCropIndex, section: TableViewSection.cropInfo.rawValue))
            }
        }
        if cropDataSource.count > 0 {
            tableView.deleteRows(at: indexPathsToDelete, with: .fade)
        } else {
            shouldEditCrops = false
            tableView.reloadData()
        }
        updateSaveButtonState()
    }
    
}

// MARK: UITableViewDelegate & UITableViewDataSource

extension GrowerDetailsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = TableViewSection(rawValue: section) else { return 0 }
        switch section {
        case .growerName:
            return 2
        case .growerInfo:
            return 4
        case .cropInfo:
            return cropDataSource.isEmpty ? 1 : cropDataSource.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = TableViewSection(rawValue: indexPath.section) else { return UITableViewCell() }
        switch section {
        case .growerName:
            return nameSectionCellSource[indexPath.row]
        case .growerInfo:
            return infoSectionCellSource[indexPath.row]
        case .cropInfo:
            guard !cropDataSource.isEmpty else {
                return cropEmptyStateInfoCell
            }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LabeledTextFieldAccessoryTableViewCell.nibName, for: indexPath) as? LabeledTextFieldAccessoryTableViewCell else {
                return UITableViewCell()
            }
            
            let cropName = cropDataSource[indexPath.row].cropID.cropNameFromID()
            cell.titleLabelText = cropName
            cell.delegate = self
            cell.textFieldKeyboardType = .decimalPad
            cell.textFieldPlaceholder = "0"
            cell.subtitleLabelText = nil
            cell.shouldShowAcresAccessoryView = true
            cell.isCellSeparatorHidden = indexPath.isLastOf(cropDataSource)
            let acreage = Int(cropDataSource[indexPath.row].plantedAcreage)
            cell.textFieldText = acreage > 0 ? "\(acreage)" : nil
            cell.tag = indexPath.row
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = TableSectionHeaderView.fromNib
        guard let section = TableViewSection(rawValue: section) else { return .none }
        switch section {
        case .growerName:
            headerView.titleLabelText = "Grower Profile"
        case .growerInfo:
            headerView.titleLabelText = "Additional Info"
        case .cropInfo:
            return cropHeaderView
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = TableViewSection(rawValue: indexPath.section) else { return false }
        switch section {
        case .cropInfo:
            return cropDataSource.isEmpty ? false : true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let section = TableViewSection(rawValue: indexPath.section) else { return .none }
        switch section {
        case .cropInfo:
            return .delete
        default:
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCropAtIndexPath(indexPath: indexPath)
        }
    }
    
    enum TableViewSection: Int {
        case growerName
        case cropInfo
        case growerInfo
    }

}

// MARK: - SearchTableViewControllerDelegate

extension GrowerDetailsViewController: SearchTableViewControllerPresenting {
    
    func didSelectItem<T: NameSearchable>(_ searchTableViewController: SearchTableViewController<T>, item: T) {
        if T.self == Zone.self {
            guard let zone = item as? Zone else {
                log(error: "Invalid item type when pulling object from Zone Table.")
                return
            }
            if cropDataSource.isEmpty {
                zoneCell.textFieldText = zone.displayName
                grower.zoneID = zone.zoneID
            } else {
                proposedZone = zone
            }
        } else if T.self == Crop.self {
            guard let crop = item as? Crop else {
                log(error: "Invalid item type when pulling object from Crop Table.")
                return
            }
            var plantedCrop = PlantedCrop(crop: crop)
            plantedCrop.plantedCropID = UUID().uuidString
            cropDataSource.append(plantedCrop)
            tableView.reloadData()

            let indexOfNewCrop = IndexPath(row: cropDataSource.count - 1, section: 1)
            tableView.scrollToRow(at: indexOfNewCrop, at: .middle, animated: true)
            guard let cell = tableView.cellForRow(at: indexOfNewCrop) as? LabeledTextFieldAccessoryTableViewCell else {
                log(error: "Unable to retrieve as proper cell.")
                return
            }
            firstResponderCropCell = cell
        }
        updateSaveButtonState()
    }
    
}

// MARK: - LabeledTextFieldTableViewCellDelegate

extension GrowerDetailsViewController: LabeledTextFieldTableViewCellDelegate {
    
    func textFieldDidBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) {
        addKeyboardDismissGestureRecognizer()
    }
    
    func textFieldShouldBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) -> Bool {
        switch labeledTextFieldTableViewCell {
        case zoneCell:
            navigateToZoneList()
            return false
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) {
        removeKeyboardDismissGestureRecognizer()
    }
    
    func textFieldShouldChangeCharacters(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            var textFieldText = text.replacingCharacters(in: textRange, with: string)
            switch labeledTextFieldTableViewCell {
            case zoneCell:
                break
            case firstNameCell:
                grower.firstName = (textFieldText == "") ? " " : textFieldText
            case lastNameCell:
                grower.lastName = (textFieldText == "") ? " " : textFieldText
            case emailCell:
                grower.email = (textFieldText == "") ? " " : textFieldText
            case farmNameCell:
                grower.farmName = textFieldText
            case phoneNumberCell:
                labeledTextFieldTableViewCell.textFieldText = textFieldText.telephoneFormat()
                grower.phoneNumber = (textFieldText == "") ? " " : textFieldText
                return false
            default:
                break
            }
        updateSaveButtonState()
        }
        return true
    }
        
}

// MARK: - LabeledTextFieldAccessoryTableViewCellDelegate

extension GrowerDetailsViewController: LabeledTextFieldAccessoryTableViewCellDelegate {
    
    func textFieldDidBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField) {
        addKeyboardDismissGestureRecognizer()
    }

    func textFieldDidEndEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField) {
        removeKeyboardDismissGestureRecognizer()
    }
    
    func textFieldShouldChangeCharacters(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let textFieldText = text.replacingCharacters(in: textRange, with: string)
            cropDataSource[labeledTextFieldTableViewCell.tag].plantedAcreage = Double(textFieldText) ?? 0
            grower.crops = cropDataSource
            
            if let index = plantedCropsEdited.firstIndex(where: { $0.plantedCropID == cropDataSource[labeledTextFieldTableViewCell.tag].plantedCropID }) {
                plantedCropsEdited[index] = cropDataSource[labeledTextFieldTableViewCell.tag]
            } else {
                plantedCropsEdited.append(cropDataSource[labeledTextFieldTableViewCell.tag])
            }
        }
        updateSaveButtonState()
        return true
    }
    
}

// MARK: - TableSectionHeaderViewDelegate

extension GrowerDetailsViewController: TableSectionHeaderViewDelegate {
    
    func didTapPlusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton) {
        navigateToCropList()
    }
    
    func didTapMinusButton(_ tableSectionHeaderView: TableSectionHeaderView, sender: UIButton) {
        shouldEditCrops = !shouldEditCrops
    }
}

// MARK: - GrowerDetailsViewControllerDelegate

protocol GrowerDetailsViewControllerDelegate: AnyObject {
    func didAddGrower(_ viewController: GrowerDetailsViewController, grower: Grower)
}
