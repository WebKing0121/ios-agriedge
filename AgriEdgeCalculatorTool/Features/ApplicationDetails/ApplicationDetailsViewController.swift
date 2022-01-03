//
//  ApplicationDetailsViewController.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/8/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

protocol ApplicationDetailsViewControllerDelegate: AnyObject {
    func applicationDetailsDidSaveApplications(_ applicationDetailsViewController: ApplicationDetailsViewController, applications: [Application])
    func applicationDetailsDidDeleteApplication(_ applicationDetailsViewController: ApplicationDetailsViewController, application: Application)
}

class ApplicationDetailsViewController: BaseTableViewController, KeyboardDismissing, AnalyticsTracking {

    // MARK: Outlets
    
    @IBOutlet private weak var deleteApplicationButton: UIBarButtonItem!
    
    // MARK: Properties
    
    weak var delegate: ApplicationDetailsViewControllerDelegate?
    
    override var primaryButton: (title: String, action: (() -> Void))? {
        return (title: "Save Application", action: {
            self.saveApplication()
        })
    }
    
    var grower: Grower?
    var editApplication: Application? {
        didSet {
            let predicate = NSPredicate(format: "productID = %@", editApplication?.productID ?? "")
            guard let productObject = PersistenceLayer().fetch(ProductObject.self, predicate: predicate)?.first,
                let crop = grower?.crops?.first(where: { $0.cropID == editApplication?.cropID }) else { return }
            selectedProduct = Product(productObject: productObject)
            let appliedRate = Double(editApplication?.appliedRate ?? "") ?? 0.0
            let appliedTotal = Double(editApplication?.appliedAcreage ?? "") ?? 0.0
            let cellValues = [  0: "\(editApplication?.appliedRate ?? "")",
                                1: "\(editApplication?.appliedUoM.rateDisplayName ?? "")",
                                2: "\(appliedRate * appliedTotal)",
                                3: "\(editApplication?.appliedUoM.totalDisplayName ?? "")"]

            selectedCrops = [crop]
            let isEnrolledInAgriClime = (editApplication?.enrollInAgriClime ?? 0) == 1 ? true : false
            let agriClimeEnrollment = AgriClimeEnrollment(cropID: crop.cropID, isEnrolled: isEnrolledInAgriClime, productQuantity: editApplication?.agriClimeQuantity)
            insertAreaAndRateSections(rateHeaderName: "Application Rate", addingNumberOfSections: 2, for: crop, cellValues: cellValues, agriClimeEnrollment: agriClimeEnrollment)
            insertAreaCell(for: crop, appliedAcres: editApplication?.appliedAcreage)
        }
    }
    
    var specificCropsSelected = [String]() {
        didSet {
            toggleButtonContainerCell.enabledButtons = specificCropsSelected
            specificCropsSelected.forEach({ crop in
                guard let plantedCrop = grower?.crops?.filter({ $0.cropID.cropNameFromID() == crop }).first else { return }
                if selectedProduct != nil {
                    self.insertAreaAndRateSections(rateHeaderName: "Application Rate", addingNumberOfSections: 2, for: plantedCrop)
                    self.insertAreaCell(for: plantedCrop)
                }
                selectedCrops.append(plantedCrop)
            })
            
        }
    }
    
    private var cropsCellHeight: CGFloat = 0.0
    private var useSameRateForAllCrops: Bool = true
    private var selectedPickerCellIndexPath: (section: Int, row: Int)?
    private var selectedProduct: Product?
    
    private var numberOfSections = 2
    private var numberOfAreaRows = 0
    private var showMultiCropToggle = false
    private var selectedCrops = [PlantedCrop]()
    private var editedValues = false
    
    // MARK: Target Crop Section
    
    private lazy var targetCropHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "Target Crop"
        return headerView
    }()
    
    private lazy var toggleButtonContainerCell: ToggleButtonContainerTableViewCell = {
        guard let crops = grower?.crops else { return ToggleButtonContainerTableViewCell() }
        let cell = ToggleButtonContainerTableViewCell()
        cell.delegate = self
        return cell
    }()
    
    private lazy var useSameRateToggleCell: LabeledToggleTableViewCell = {
        let cell = LabeledToggleTableViewCell.fromNib
        cell.titleLabelText = "Use the same rate for all crops"
        cell.isCellSeparatorHidden = true
        cell.delegate = self
        return cell
    }()

    // MARK: Product Section
    
    private lazy var productHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "Product"
       return headerView
    }()
    
    private lazy var selectProductButtonCell: StyledButtonTableViewCell = {
        let cell = StyledButtonTableViewCell.fromNib
        cell.buttonTitleLabelText = "Select Product"
        cell.buttonType = (.tertiary, .teal)
        cell.delegate = self
        return cell
    }()
    
    private var selectedProductCell: LabeledButtonTableViewCell {
        let cell = LabeledButtonTableViewCell.fromNib
        cell.titleLabelText = selectedProduct?.displayName
        cell.buttonLabelText = "change product"
        cell.delegate = self
        return cell
    }
    
    // MARK: Area Section
    
    private var cropAreaCells = [LabeledTextFieldAccessoryTableViewCell]()
    
    private lazy var areaHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "Application Area"
        return headerView
    }()
    
    private func areaCell(for crop: PlantedCrop, appliedAcres: String? = nil) -> LabeledTextFieldAccessoryTableViewCell {
        let cell = LabeledTextFieldAccessoryTableViewCell.fromNib
        cell.titleLabelText = crop.cropID.cropNameFromID()
        cell.textFieldText = appliedAcres
        cell.subtitleLabelText = "\(Int(crop.plantedAcreage)) acres (total)"
        cell.textFieldKeyboardType = .decimalPad
        cell.textFieldPlaceholder = "0"
        cell.shouldShowAcresAccessoryView = true
        cell.delegate = self
        return cell
    }
    
    // MARK: Rate Section

    private var rateSections = [(crop: PlantedCrop?, header: TableSectionHeaderView, cellValues: [Int: String])]()
    private var agriClimeEnrollments = [AgriClimeEnrollment]()
    
    private var rateSectionCells: [LabeledTextFieldTableViewCell] {
        return [rateCell, rateUnitsCell, totalQuantityCell, quantityUnitsCell]
    }
    
    private func rateHeaderView(titled title: String) -> TableSectionHeaderView {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = title
        return headerView
    }
    
    private var rateCell: LabeledTextFieldTableViewCell {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "Application Rate"
        cell.textFieldPlaceholder = "rate"
        cell.textFieldKeyboardType = .decimalPad
        cell.delegate = self
        return cell
    }
    
    private var rateUnitsCell: LabeledTextFieldTableViewCell {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "Rate Units"
        cell.textFieldPlaceholder = "units"
        cell.delegate = self
        cell.shouldShowArrowAccessoryView = true
        return cell
    }
    
    private var totalQuantityCell: LabeledTextFieldTableViewCell {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "Total Quantity"
        cell.textFieldPlaceholder = "quantity"
        cell.textFieldKeyboardType = .decimalPad
        cell.delegate = self
        return cell
    }
    
    private var quantityUnitsCell: LabeledTextFieldTableViewCell {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "Quantity Units"
        cell.textFieldPlaceholder = "units"
        cell.delegate = self
        cell.shouldShowArrowAccessoryView = true
        return cell
    }
    
    private var useAgriClimeCell: LabeledToggleTableViewCell {
        let cell = LabeledToggleTableViewCell.fromNib
        cell.titleLabelText = "Enroll in AgriClime"
        cell.isCellSeparatorHidden = false
        cell.delegate = self
        return cell
    }

    private var agriClimeQuantityCell: LabeledTextFieldTableViewCell {
        let cell = LabeledTextFieldTableViewCell.fromNib
        cell.titleLabelText = "Total AgriClime Quantity"
        cell.textFieldPlaceholder = "quantity units"
        cell.textFieldKeyboardType = .decimalPad
        cell.delegate = self
        return cell
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalytics(screen: .applicationDetails)
        addKeyboardDismissGestureRecognizer()
        isPrimaryButtonEnabled = false
        view.backgroundColor = SemanticCustomColor.tableBackground.uiColor
        
        if editApplication == nil {
            self.navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let crops = grower?.crops else { return }
        if crops.count == 1,
            editApplication == nil {
            selectedCrops = crops
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSaveApplicatonButtonState()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let crops = grower?.crops else { return }
        let cropNames = crops.compactMap({ $0.cropID.cropNameFromID() })
        self.cropsCellHeight = toggleButtonContainerCell.configureForHeight(with: cropNames, viewWidth: self.view.bounds.width)
        toggleButtonContainerCell.enabledButtons = selectedCrops.map({ $0.cropID.cropNameFromID() ?? "" })
        super.viewDidLayoutSubviews()
    }
    
    // MARK: Save Application
    
    private func saveApplication() {
        logAnalytics(event: .saveApplication, parameters: ["use_same_rate": String(useSameRateForAllCrops)])
        let applications = cropAreaCells.compactMap({
            (cell: LabeledTextFieldAccessoryTableViewCell) -> Application? in
            
            guard let crop = plantedCropFromCropName(cropName: cell.titleLabelText) else { return nil }

            let appliedRateSection = useSameRateForAllCrops ? rateSections[0] : (rateSections.filter({ $0.crop?.cropID == crop.cropID }).first ?? rateSections[0])
            guard let productID = selectedProduct?.productID,
                let appliedAcreage = cell.textFieldText,
                let appliedRate = appliedRateSection.cellValues[0],
                let appliedUoMString = appliedRateSection.cellValues[1],
                let appliedUoM = UnitOfMeasure.init(rateDisplayName: appliedUoMString) else { return nil }

            // fix when you go to edit an app and add a new crop but keep useSameRateForAllCrops ON
            var applicationID = UUID().uuidString
            if let editingApplicationID = editApplication?.applicationID,
                useSameRateForAllCrops,
                editApplication?.cropID == crop.cropID {
                    applicationID = editingApplicationID
            }
            
            let agriClimeEnrollment = agriClimeEnrollments.filter { $0.cropID == crop.cropID }.first
            let enrollInAgriClime = (agriClimeEnrollment?.isEnrolled ?? false) ? 1 : 0
            let agriClimeQuantityString = agriClimeEnrollment?.productQuantity ?? "0"
            let application = Application(applicationID: applicationID,
                                          productID: productID,
                                          cropID: crop.cropID,
                                          appliedAcreage: appliedAcreage,
                                          appliedRate: appliedRate,
                                          appliedUoM: appliedUoM,
                                          enrollInAgriClime: enrollInAgriClime,
                                          agriClimeQuantity: agriClimeQuantityString)
            return application

        })

        delegate?.applicationDetailsDidSaveApplications(self, applications: applications)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func deleteApplication(_ sender: UIBarButtonItem) {
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.logAnalytics(event: .deleteApplication)
            guard let application = self.editApplication else { return }
            self.delegate?.applicationDetailsDidDeleteApplication(self, application: application)
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        showChoiceAlert(title: "Are you sure you want to delete this application?", message: nil, alertActions: [deleteAction, cancelAction])

    }
    
    @IBAction private func cancelApplication(_ sender: Any) {
        logAnalytics(event: .cancelApplication)
        if editedValues {
            let confirmAction = UIAlertAction(title: "Yes, leave", style: .destructive) { _ in
                self.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            showChoiceAlert(title: "Are you sure?", message: "Any unsaved changes will be lost.", alertActions: [confirmAction, cancelAction])
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    // MARK: Navigation
    
    private func navigateToProductsList() {
        logAnalytics(screen: .productsList)
        DispatchQueue.main.async {
            guard let productObjects = DualPersistenceLayer().fetch(ProductObject.self) else {
                log(error: "error fetching products from realm")
                return
            }
            
            let products = productObjects.map({
                (productObject: ProductObject) -> Product in
                return Product(productObject: productObject)
            })

            self.pushSearchViewController(title: "Product List", dataSource: products)
        }
    }
    
    private func navigateToChoiceModal(isRateSection: Bool) {
        if isRateSection {
            logAnalytics(screen: .rateModal)
        } else {
            logAnalytics(screen: .quantityModal)
        }
        
        DispatchQueue.main.async {
            self.dismissKeyboard()
            let choiceModalInfo = ChoiceModalInfo(titleLabel: "Rate Unit", subtitleLabel: "Choose from the options below", closeButtonTitle: "Cancel", choiceButtonTitles: isRateSection ? self.selectedProduct?.measurementUnit.rateUnitOptions : self.selectedProduct?.measurementUnit.totalUnitOptions)
            self.showChoiceModal(withInfo: choiceModalInfo)
        }
    }
        
    // MARK: Helpers
    
    private func updateSaveApplicatonButtonState() {
        let isMissingAcres = cropAreaCells.contains(where: { cell in
            guard let acresTextFieldText = cell.textFieldText else { return true }
            return acresTextFieldText.isEmpty || acresTextFieldText == "0"
        })
        
        var isMissingRates = [Bool]()
        for section in rateSections {
            guard !section.cellValues.isEmpty else {
                isMissingRates.append(true)
                break
            }
            
            isMissingRates.append(section.cellValues.count < 4 ||
                section.cellValues.contains(where: { $0.value.isEmpty }))
        }
        
        if isMissingAcres || isMissingRates.contains(where: { $0 == true }) || cropAreaCells.isEmpty {
            isPrimaryButtonEnabled = false
        } else {
            isPrimaryButtonEnabled = true
        }
    }
    
    private func plantedCropFromCropName(cropName: String?) -> PlantedCrop? {
        guard let cropName = cropName,
            let grower = self.grower,
            let crops = grower.crops else { return nil }

        let cropNamePredicate = NSPredicate(format: "displayName = %@", cropName)
        guard let cropObject = PersistenceLayer().fetch(CropObject.self, predicate: cropNamePredicate)?.first else { return nil }
        
        return crops.first(where: { cropObject.cropID == $0.cropID })
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ApplicationDetailsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (cropAreaCells.count > 0 && selectedProduct != nil) ? numberOfSections : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TableViewSection.targetCrop.rawValue:
            return (showMultiCropToggle) ? 2 : 1
        case TableViewSection.product.rawValue:
            return 1
        case TableViewSection.area.rawValue:
            return numberOfAreaRows
        case _ where section >= TableViewSection.rate.rawValue:
            let agriClimeZonePrice = (selectedProduct?.agriClimeRedemptionZonePrice ?? [:])[grower?.zoneID ?? ""]
            if agriClimeZonePrice == nil { //AgriClime is not enabled for this Product/Zone
                return 4
            } else {
                return 6
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case TableViewSection.targetCrop.rawValue:
            if indexPath.row == 0 {
                return toggleButtonContainerCell
            } else {
                return useSameRateToggleCell
            }
        case TableViewSection.product.rawValue:
            return selectedProduct == nil ? selectProductButtonCell : selectedProductCell
        case TableViewSection.area.rawValue:
            let cell = cropAreaCells[indexPath.row]
            if cell == cropAreaCells.last {
                cell.isCellSeparatorHidden = true
            }
            return cropAreaCells[indexPath.row]
        case _ where indexPath.section >= TableViewSection.rate.rawValue:
            if indexPath.row <= 3 {
                let cell = rateSectionCells[indexPath.row]
                cell.textFieldText = rateSections[indexPath.section - 3].cellValues[indexPath.row]
                return cell
            } else if indexPath.row == 4 {
                let cell = useAgriClimeCell
                cell.isToggleOn = agriClimeEnrollments[indexPath.section - 3].isEnrolled
                return cell
            } else {
                let cell = agriClimeQuantityCell
                cell.textFieldText = agriClimeEnrollments[indexPath.section - 3].productQuantity
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return cropsCellHeight
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case TableViewSection.targetCrop.rawValue:
            return targetCropHeaderView
        case TableViewSection.product.rawValue:
            return productHeaderView
        case TableViewSection.area.rawValue:
            return areaHeaderView
        case _ where section >= TableViewSection.rate.rawValue:
            return rateSections[section - 3].header
        default:
            return UIView()
        }
    }
    
    enum TableViewSection: Int, CaseIterable {
        case targetCrop
        case product
        case area
        case rate
    }
    
}

// MARK: - SearchTableViewControllerDelegate

extension ApplicationDetailsViewController: SearchTableViewControllerPresenting {
    
    func didSelectItem<T: NameSearchable>(_ searchTableViewController: SearchTableViewController<T>, item: T) {
        editedValues = true
        if selectedProduct != nil {
            selectedProduct = item as? Product
            rateSections = rateSections.map({
                (crop: PlantedCrop?, header: TableSectionHeaderView, cellValues: [Int: String]) in
                var values = cellValues
                values[1] = selectedProduct?.measurementUnit.rateDisplayName
                values[3] = selectedProduct?.measurementUnit.totalDisplayName
                return (crop, header, values)
            })
            agriClimeEnrollments = rateSections.map({
                (crop: PlantedCrop?, _, _) in
                return AgriClimeEnrollment(cropID: crop?.cropID ?? "", isEnrolled: false, productQuantity: nil)
            })
            tableView.reloadData()
        } else {
            tableView.beginUpdates()
            selectedProduct = item as? Product
            if selectedCrops.isEmpty {
                tableView.endUpdates()
                tableView.reloadData()
                return
            }
            if useSameRateToggleCell.isToggleOn {
                guard let firstCrop = selectedCrops.first else { return }
                insertAreaAndRateSections(rateHeaderName: "Application Rate", addingNumberOfSections: 2, for: firstCrop)
                insertAreaCell(for: firstCrop)
                selectedCrops.suffix(from: 1).forEach { plantedCrop in
                    insertAreaCell(for: plantedCrop, at: numberOfAreaRows)
                }
            } else {
                guard let firstCrop = selectedCrops.first else { return }
                insertAreaAndRateSections(rateHeaderName: "\(firstCrop.cropID.cropNameFromID() ?? "") Application Rate", addingNumberOfSections: 2, for: firstCrop)
                insertAreaCell(for: firstCrop)
                selectedCrops.suffix(from: 1).forEach { plantedCrop in
                    insertAreaAndRateSections(rateHeaderName: "\(plantedCrop.cropID.cropNameFromID() ?? "") Application Rate", addingNumberOfSections: 1, at: IndexSet(integer: numberOfSections), for: plantedCrop)
                    insertAreaCell(for: plantedCrop, at: numberOfAreaRows)
                }
            }
            tableView.endUpdates()
            tableView.reloadData()
        }
    }
    
}

// MARK: - ChoiceModalViewControllerDelegate

extension ApplicationDetailsViewController: ChoiceModalPresenting {
    
    func choiceModalDidSelectItem(_ choiceModalViewController: ChoiceModalViewController, selection: String?) {
        editedValues = true
        guard let selectedPickerCellIndexPath = selectedPickerCellIndexPath else { return }
        let indexPath = IndexPath(row: selectedPickerCellIndexPath.row, section: selectedPickerCellIndexPath.section)
        guard let selectedPickerTextFieldCell = tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell else { return }

        rateSections[indexPath.section - 3].cellValues[indexPath.row] = selection
        selectedPickerTextFieldCell.textFieldText = selection
        var acreage = 1.0
        if useSameRateToggleCell.isToggleOn {
            acreage = 0.0
            cropAreaCells.forEach({
                acreage += Double($0.textFieldText ?? "0.0") ?? 0.0
            })
            if acreage == 0 {
                acreage = 1.0
            }
        } else {
            let index = (indexPath.section == TableViewSection.area.rawValue) ? indexPath.row : indexPath.section - TableViewSection.rate.rawValue
            acreage = Double(cropAreaCells[index].textFieldText ?? "1.0") ?? 1.0
        }
        guard let rateUoMText = rateSections[indexPath.section - 3].cellValues[1],
            let totalUoMText = rateSections[indexPath.section - 3].cellValues[3],
            let rateUoM = UnitOfMeasure(rateDisplayName: rateUoMText)?.ratio,
            let totalUoM = UnitOfMeasure(totalDisplayName: totalUoMText)?.ratio else { return }
        switch indexPath.row {
        case 1, 3:
            guard let rate = Double(rateSections[indexPath.section - 3].cellValues[0] ?? "") else { return }
            let totalBeforeConversion = acreage * rate
            rateSections[indexPath.section - 3].cellValues[2] = "\(totalBeforeConversion * totalUoM / rateUoM)"
            self.tableView.reloadData()
        default:
            break
        }
        updateSaveApplicatonButtonState()
    }
    
}

// MARK: - LabeledTextFieldAccessoryTableViewCellDelegate

extension ApplicationDetailsViewController: LabeledTextFieldAccessoryTableViewCellDelegate {
    
    func textFieldShouldChangeCharacters(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        editedValues = true
        var didUpdateTextField = false
        guard let indexPath = tableView.indexPath(for: labeledTextFieldTableViewCell) else { return !didUpdateTextField }
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let newTextFieldText = text.replacingCharacters(in: textRange, with: string)
            switch indexPath.section {
            case TableViewSection.area.rawValue:
                labeledTextFieldTableViewCell.textFieldText = newTextFieldText
                didUpdateTextField = true
            default: break
            }
            var acreage = 1.0
            if useSameRateToggleCell.isToggleOn {
                acreage = 0.0
                cropAreaCells.forEach({
                    acreage += Double($0.textFieldText ?? "0.0") ?? 0.0
                })
                if acreage == 0 {
                    acreage = 1.0
                }
            } else {
                let index = (indexPath.section == TableViewSection.area.rawValue) ? indexPath.row : indexPath.section - TableViewSection.rate.rawValue
                acreage = Double(cropAreaCells[index].textFieldText ?? "1.0") ?? 1.0
            }
            switch indexPath.section {
            case TableViewSection.area.rawValue:
                let index = (useSameRateToggleCell.isToggleOn) ? 0 : indexPath.row
                
                guard let rateUoMText = rateSections[index].cellValues[1],
                    let totalUoMText = rateSections[index].cellValues[3],
                    let rateUoM = UnitOfMeasure(rateDisplayName: rateUoMText)?.ratio,
                    let totalUoM = UnitOfMeasure(totalDisplayName: totalUoMText)?.ratio,
                    let rate = Double(rateSections[index].cellValues[0] ?? "") else { return !didUpdateTextField }
                let totalBeforeConversion = acreage * rate
                rateSections[index].cellValues[2] = "\(totalBeforeConversion * totalUoM / rateUoM)"
                guard let cellToEdit = tableView.cellForRow(at: IndexPath(row: 2, section: (useSameRateToggleCell.isToggleOn) ? 3 : indexPath.row + 3)) as? LabeledTextFieldTableViewCell else { return !didUpdateTextField }
                cellToEdit.textFieldText = rateSections[index].cellValues[2]
                updateSaveApplicatonButtonState()
                return !didUpdateTextField
            default:
                break
            }
        }
        return !didUpdateTextField
    }
    
    func textFieldDidEndEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldAccessoryTableViewCell, textField: UITextField) {
        guard let indexPath = tableView.indexPath(for: labeledTextFieldTableViewCell) else { return }
        switch indexPath.section {
        case TableViewSection.area.rawValue:
            let typedDouble = Double(textField.text ?? "0.0") ?? 0.0
            if typedDouble == 0 {
                showAlert(title: "Entered area is zero", message: "Please enter an application area greater than 0.", completion: nil)
                updateSaveApplicatonButtonState()
            }
        default:
            break
        }
    }

}

// MARK: - LabeledTextFieldTableViewCellDelegate

extension ApplicationDetailsViewController: LabeledTextFieldTableViewCellDelegate {
    
    func textFieldShouldBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) -> Bool {
        guard let indexPath = tableView.indexPath(for: labeledTextFieldTableViewCell) else {
            log(error: "unable to find the cell")
            return true
        }
        if indexPath.section >= TableViewSection.rate.rawValue &&
            (indexPath.row == 1 || indexPath.row == 3) {
            selectedPickerCellIndexPath = (section: indexPath.section, row: indexPath.row)
            navigateToChoiceModal(isRateSection: (indexPath.row == 1))
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField) {
        guard selectedProduct != nil else {
            showAlert(title: "Choose a Product", message: "Please choose a product before entering Application Area and Rate")
            return
        }
    }
    
    func textFieldShouldChangeCharacters(_ labeledTextFieldTableViewCell: LabeledTextFieldTableViewCell, textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        editedValues = true
        guard let indexPath = tableView.indexPath(for: labeledTextFieldTableViewCell) else { return true }
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let textFieldText = text.replacingCharacters(in: textRange, with: string)
            var acreage = 1.0
            if useSameRateToggleCell.isToggleOn {
                acreage = 0.0
                cropAreaCells.forEach({
                    acreage += Double($0.textFieldText ?? "0.0") ?? 0.0
                })
                if acreage == 0 {
                    acreage = 1.0
                }
            } else {
                let index = (indexPath.section == TableViewSection.area.rawValue) ? indexPath.row : indexPath.section - TableViewSection.rate.rawValue
                acreage = Double(cropAreaCells[index].textFieldText ?? "1.0") ?? 1.0
            }
            switch indexPath.section {
            case _ where indexPath.section >= TableViewSection.rate.rawValue:
                self.rateSections[indexPath.section - 3].cellValues[indexPath.row] = textFieldText
                guard let rateUoMText = rateSections[indexPath.section - 3].cellValues[1],
                    let totalUoMText = rateSections[indexPath.section - 3].cellValues[3],
                    let rateUoM = UnitOfMeasure(rateDisplayName: rateUoMText)?.ratio,
                    let totalUoM = UnitOfMeasure(totalDisplayName: totalUoMText)?.ratio else { return true }
                switch indexPath.row {
                case 0:
                    guard let rate = Double(rateSections[indexPath.section - 3].cellValues[0] ?? "") else {
                        self.updateSaveApplicatonButtonState()
                        return true
                    }
                    let totalBeforeConversion = acreage * rate
                    rateSections[indexPath.section - 3].cellValues[2] = "\(totalBeforeConversion * totalUoM / rateUoM)"
                    guard let cellToEdit = tableView.cellForRow(at: IndexPath(row: 2, section: indexPath.section)) as? LabeledTextFieldTableViewCell else {
                        self.updateSaveApplicatonButtonState()
                        return true
                    }
                    cellToEdit.textFieldText = rateSections[indexPath.section - 3].cellValues[2]
                    self.updateSaveApplicatonButtonState()
                case 2:
                    guard let total = Double(rateSections[indexPath.section - 3].cellValues[2] ?? "") else {
                        self.updateSaveApplicatonButtonState()
                        return true
                    }
                    let rateBeforeConversion = total / acreage
                    rateSections[indexPath.section - 3].cellValues[0] = "\(rateBeforeConversion * rateUoM / totalUoM)"
                    guard let cellToEdit = tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? LabeledTextFieldTableViewCell else {
                        self.updateSaveApplicatonButtonState()
                        return true
                    }
                    cellToEdit.textFieldText = rateSections[indexPath.section - 3].cellValues[0]
                    self.updateSaveApplicatonButtonState()
                case 5:
                    agriClimeEnrollments[indexPath.section - 3].productQuantity = textFieldText
                default:
                    break
                }
                
            default:
                break
            }
        }
        return true
    }
        
}

// MARK: - ToggleButtonContainerTableViewCellDelegate

extension ApplicationDetailsViewController: ToggleButtonContainerTableViewCellDelegate {
    
    func didSelectButtonToggle(_ toggleButtonContainerTableViewCell: ToggleButtonContainerTableViewCell, button: ToggleButton, selection: String) {
        logAnalytics(event: .applicationTargetCropSelected, parameters: ["crop_type": "\(selection)"])

        guard let selectedCropName = button.titleLabel?.text,
            let crop = plantedCropFromCropName(cropName: selectedCropName) else { return }
        
        tableView.beginUpdates()
        
        if useSameRateForAllCrops {
            if button.isSelected {
                selectedCrops.append(crop)
                if selectedProduct != nil {
                    if numberOfSections == 2 {
                        insertAreaAndRateSections(rateHeaderName: "Application Rate", addingNumberOfSections: 2, for: crop)
                        insertAreaCell(for: crop)
                    } else if numberOfSections == 4 {
                        insertAreaCell(for: crop, at: numberOfAreaRows)
                    }
                }
            } else {
                selectedCrops.removeAll(where: { $0.cropID == crop.cropID })
                if selectedProduct != nil {
                    if numberOfAreaRows == 1 {
                        removeAreaAndRateSections()
                    } else if numberOfAreaRows > 1 {
                        removeAreaRow(named: selectedCropName)
                    }
                }
            }
        } else {
            if button.isSelected {
                selectedCrops.append(crop)
                if selectedProduct != nil {
                    if numberOfSections == 2 {
                        insertAreaAndRateSections(rateHeaderName: "\(selectedCropName) Application Rate", addingNumberOfSections: 2, for: crop)
                        insertAreaCell(for: crop)
                    } else if numberOfSections >= 4 {
                        insertAreaAndRateSections(rateHeaderName: "\(selectedCropName) Application Rate", addingNumberOfSections: 1, at: IndexSet(integer: numberOfSections), for: crop)
                        insertAreaCell(for: crop, at: numberOfAreaRows)
                    }
                }
            } else {
                selectedCrops.removeAll(where: { $0.cropID == crop.cropID })
                if selectedProduct != nil {
                    if numberOfSections == 4 {
                        removeAreaAndRateSections()
                    } else if numberOfSections > 4 {
                        removeRateSection(named: selectedCropName)
                        removeAreaRow(named: selectedCropName)
                    }
                }
            }
        }
        
        if (cropAreaCells.count > 1 || selectedCrops.count > 1) && !showMultiCropToggle {
            showMultiCropToggle = true
            tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        } else if showMultiCropToggle && (cropAreaCells.count <= 1 && selectedCrops.count <= 1) {
            showMultiCropToggle = false
            tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        }
        
        tableView.endUpdates()
    }
    
    private func insertAreaAndRateSections(rateHeaderName: String, addingNumberOfSections: Int, at indexSet: IndexSet = IndexSet(arrayLiteral: 2, 3), for crop: PlantedCrop, cellValues: [Int: String]? = nil, agriClimeEnrollment: AgriClimeEnrollment? = nil) {
       
        var values = [Int: String]()
        if let cellValues = cellValues {
            values = cellValues
        } else {
            values[1] = selectedProduct?.measurementUnit.rateDisplayName
            values[3] = selectedProduct?.measurementUnit.totalDisplayName
        }
        rateSections.append((crop: crop, header: rateHeaderView(titled: rateHeaderName), cellValues: values))
        let thisAgriClimeEnrollment = agriClimeEnrollment ?? AgriClimeEnrollment(cropID: crop.cropID, isEnrolled: false, productQuantity: nil)
        agriClimeEnrollments.append(thisAgriClimeEnrollment)
        tableView.insertSections(indexSet, with: .fade)
        numberOfSections += addingNumberOfSections
        updateSaveApplicatonButtonState()
    }

    private func insertAreaCell(for crop: PlantedCrop, at row: Int = 0, appliedAcres: String? = nil) {
        var initialAcres = appliedAcres
        if initialAcres == nil {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ""
            let acreageString = numberFormatter.string(from: NSNumber(value: crop.plantedAcreage))
            initialAcres = acreageString
        }
        cropAreaCells.append(areaCell(for: crop, appliedAcres: initialAcres))
        tableView.insertRows(at: [IndexPath(row: row, section: 2)], with: .fade)
        numberOfAreaRows += 1
        updateSaveApplicatonButtonState()
    }
    
    private func removeAreaAndRateSections() {
        rateSections.removeAll()
        agriClimeEnrollments.removeAll()
        tableView.deleteSections(IndexSet(arrayLiteral: 2, 3), with: .fade)
        numberOfSections -= 2

        cropAreaCells.removeAll()
        tableView.deleteRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
        numberOfAreaRows -= 1
    }
    
    private func removeAreaRow(named cropname: String) {
        let rowIndexToDelete = cropAreaCells.firstIndex(where: { $0.titleLabelText == cropname }) ?? 0
        cropAreaCells.remove(at: rowIndexToDelete)
        tableView.deleteRows(at: [IndexPath(row: rowIndexToDelete, section: 2)], with: .fade)
        numberOfAreaRows -= 1
    }
    
    private func removeRateSection(named cropname: String) {
        let sectionIndexToDelete = rateSections.firstIndex(where: { $0.header.titleLabelText?.contains(cropname) ?? false }) ?? 0
        rateSections.remove(at: sectionIndexToDelete)
        agriClimeEnrollments.remove(at: sectionIndexToDelete)
        tableView.deleteSections(IndexSet(integer: sectionIndexToDelete + 3), with: .fade)
        numberOfSections -= 1
    }
    
}

// MARK: - LabeledToggleTableViewCellDelegate

extension ApplicationDetailsViewController: LabeledToggleTableViewCellDelegate {
    
    func didToggleSwitch(_ labeledToggleTableViewCell: LabeledToggleTableViewCell, sender: UISwitch) {
        
        if labeledToggleTableViewCell === useSameRateToggleCell {
            handleSameRateToggleAction(sender: sender)
        } else {
            // This is an AgriClime enrollment toggle
            guard let indexPath = tableView.indexPath(for: labeledToggleTableViewCell) else { return }
            agriClimeEnrollments[indexPath.section - 3].isEnrolled = sender.isOn
        }
    }
    
    private func handleSameRateToggleAction(sender: UISwitch) {
        useSameRateForAllCrops = sender.isOn

        logAnalytics(event: .useSameRateToggle, parameters: ["use_same_rate": String(useSameRateForAllCrops)])

        tableView.beginUpdates()
        
        if useSameRateForAllCrops {
            if numberOfAreaRows > 0 && selectedProduct != nil {
                rateSections.removeAll()
                
                var values = [Int: String]()
                values[1] = selectedProduct?.measurementUnit.rateDisplayName
                values[3] = selectedProduct?.measurementUnit.totalDisplayName
                rateSections.append((crop: nil, header: rateHeaderView(titled: "Application Rate"), cellValues: values))
                agriClimeEnrollments.append(AgriClimeEnrollment(cropID: "", isEnrolled: false, productQuantity: nil))
                if numberOfAreaRows > 1 {
                    var indexesToRemove = IndexSet()
                    for index in 0..<(numberOfAreaRows - 1) {
                        indexesToRemove.insert(index + 3)
                    }
                    tableView.deleteSections(indexesToRemove, with: .fade)
                } else {
                    tableView.reloadSections(IndexSet(integer: 3), with: .fade)
                }
                
                numberOfSections = 4
            }
        } else {
            if numberOfAreaRows > 0 && selectedProduct != nil {
                rateSections.removeAll()
                agriClimeEnrollments.removeAll()
                for index in 0..<(numberOfAreaRows) {
                    guard let crop = plantedCropFromCropName(cropName: cropAreaCells[index].titleLabelText) else { return }
                    
                    let cropName = cropAreaCells[index].titleLabelText ?? ""
                    var values = [Int: String]()
                    values[1] = selectedProduct?.measurementUnit.rateDisplayName
                    values[3] = selectedProduct?.measurementUnit.totalDisplayName
                    rateSections.append((crop: crop, header: rateHeaderView(titled: "\(cropName) Application Rate"), cellValues: values))
                    agriClimeEnrollments.append(AgriClimeEnrollment(cropID: crop.cropID, isEnrolled: false, productQuantity: nil))
                }
                
                if numberOfAreaRows > 1 {
                    var indexesToAdd = IndexSet()
                    for index in 0..<(numberOfAreaRows - 1) {
                        indexesToAdd.insert(index + 3)
                    }
                    tableView.insertSections(indexesToAdd, with: .fade)
                } else {
                    tableView.reloadSections(IndexSet(integer: 3), with: .fade)
                }
                
                numberOfSections = numberOfAreaRows + 3
            }
        }
        
        updateSaveApplicatonButtonState()
        
        tableView.endUpdates()
        
    }
    
}

// MARK: - BorderedButtonTableViewCellDelegate

extension ApplicationDetailsViewController: StyledButtonTableViewCellDelegate {
    
    func didTapButton(_ borderedButtonTableViewCell: StyledButtonTableViewCell, sender: StyledButton) {
        if borderedButtonTableViewCell == selectProductButtonCell {
            navigateToProductsList()
        }
    }
    
}

// MARK: - LabeledButtonTableViewCellDelegate

extension ApplicationDetailsViewController: LabeledButtonTableViewCellDelegate {
    
    func didTapButton(_ labeledButtonTableViewCell: LabeledButtonTableViewCell, sender: UIButton) {
        navigateToProductsList()
    }
    
}

private class AgriClimeEnrollment {
    var cropID: String
    var isEnrolled: Bool
    var productQuantity: String?
    
    init(cropID: String, isEnrolled: Bool, productQuantity: String?) {
        self.cropID = cropID
        self.isEnrolled = isEnrolled
        self.productQuantity = productQuantity
    }
}
