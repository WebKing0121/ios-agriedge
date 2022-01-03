//
//  RebateViewController.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/18/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Pulley

class RebateViewController: UIViewController {
    
    // MARK: Types
    
    private enum Segment: Int {
        case cropProtection = 0, seed = 1 //value matches segmentedControl index
    }
    
    // MARK: Outlets

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    // MARK: Properties
    
    weak var delegate: RebateViewControllerDelegate?
    weak var pulleyDrawerDelegate: RebateViewControllerPulleyDelegate?
    private var selectedSegment = Segment.cropProtection {
        didSet {
            switch selectedSegment {
            case .cropProtection:
                segmentedControl.selectedSegmentTintColor = UIColor(named: "cpSegmentColor")
            case .seed:
                segmentedControl.selectedSegmentTintColor = UIColor(named: "ghSegmentColor")
            }
        }
    }
    
    private var isDrawerRevealed = false {
        didSet {
            rebateTableHeader.seeMoreButtonLabelText = isDrawerRevealed ? "see less" : "see more"
        }
    }
    
    private var rebate: Rebate? {
        didSet {
            if RebateAttribute.costShareRebateTotal.isEnabled {
                rebateTableHeader.rebateAmountLabelText = rebate?.totalEstimatedRebateTotal ?? zeroDollars
            }
            tableView.reloadData()
        }
    }
    
    private var visibleRebateAttributes: [RebateAttribute] {
        let rebateAttributes = RebateAttribute.allCases.filter({ $0.isRebateAttribute })
        var visibleRebateAttributes = Array(rebateAttributes).filter({ $0.isEnabled })
        if rebate?.agriClimeCost == nil { //filter out AgriClime if there is not a value in Rebate
            visibleRebateAttributes = visibleRebateAttributes.filter { $0 != .agriClimeCost }
        }
        switch selectedSegment {
        case .cropProtection:
            break
        case .seed: //agriClime doesn't apply to Seeds
            visibleRebateAttributes = visibleRebateAttributes.filter { $0 != .agriClimeCost }
        }
        return visibleRebateAttributes
    }
    
    private lazy var rebateTableHeader: RebateTableHeaderView = {
        let view = RebateTableHeaderView.fromNib
        view.rebateAmountLabelText = self.zeroDollars
        view.delegate = self
        return view
    }()
    
    private var cellValues: [RebateAttribute: String] {
        switch selectedSegment {
        case .cropProtection:
            return [.costShare: rebate?.estimatedRebateTotal ?? zeroDollars,
                    .agriClimeCost: "(\(rebate?.agriClimeCost ?? zeroDollars))",
                    .tenNinetyCropsurance: rebate?.tenNinetyCropsurance ?? zeroDollars,
                    .fiftyFiftyTarget: rebate?.fiftyFiftyTarget ?? zeroDollars,
                    .capRiskManagement: rebate?.capRiskManagement ?? zeroDollars,
                    .estimatedSpendPerAcre: rebate?.estimatedSpendPerAcre ?? zeroDollars,
                    .estimatedSpend: rebate?.estimatedSpend ?? zeroDollars]
        case .seed:
            return [.costShare: rebate?.seedEstimatedRebateTotal ?? zeroDollars,
                    .tenNinetyCropsurance: rebate?.seedFiveNinetyFiveCropsurance ?? zeroDollars,
                    .fiftyFiftyTarget: rebate?.seedTwentyEightyTarget ?? zeroDollars,
                    .capRiskManagement: rebate?.seedCapRiskManagement ?? zeroDollars,
                    .estimatedSpendPerAcre: rebate?.seedEstimatedSpendPerAcre ?? zeroDollars,
                    .estimatedSpend: rebate?.seedEstimatedSpend ?? zeroDollars]
        }
    }
    
    private let zeroDollars = "$0.00"
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
        if RebateAttribute.costShareRebateTotal.isEnabled && visibleRebateAttributes.isEmpty {
            rebateTableHeader.seeMoreButtonIsHidden = true
        } else if !RebateAttribute.costShareRebateTotal.isEnabled && !visibleRebateAttributes.isEmpty {
            rebateTableHeader.rebateAmountLabelText = "Cost share thresholds"
        }
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                                for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black],
                                                for: .normal)
    }
 
    // MARK: Actions
    
    @IBAction private func segmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
        selectedSegment = Segment(rawValue: segmentedControl.selectedSegmentIndex) ?? .cropProtection
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension RebateViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRebateAttributes.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return rebateTableHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rebateAttribute = visibleRebateAttributes[indexPath.row]
        let cell = LabeledTableViewCell.fromNib
        let attributeTitle: String
        switch selectedSegment {
        case .cropProtection: attributeTitle = rebateAttribute.cpTitle
        case .seed: attributeTitle = rebateAttribute.seedTitle
        }
        cell.configure(titleLabelText: attributeTitle, accessoryLabelText: cellValues[rebateAttribute], isSeparatorHidden: indexPath.isLastOf(visibleRebateAttributes))
        cell.accessoryLabelFont = .systemFont(ofSize: 12)
        cell.accessoryLabelColor = SemanticCustomColor.secondaryInk.uiColor
        cell.backgroundColor = SemanticCustomColor.tableSectionHeaderBackground.uiColor
        if rebateAttribute == .estimatedSpend || rebateAttribute == .estimatedSpendPerAcre {
            cell.titleLabelFont = .systemFont(ofSize: 17, weight: .semibold)
        }
        return cell
    }
    
}

// MARK: - RebateTableHeaderViewDelegate

extension RebateViewController: RebateTableHeaderViewDelegate {
    
    func didTapSeeMore(_ rebateTableHeaderView: RebateTableHeaderView) {
        delegate?.rebateViewControllerDidSetDrawerPosition(self, position: isDrawerRevealed ? .collapsed : .partiallyRevealed)
    }

}

// MARK: - PlanDetailsViewControllerDelegate

extension RebateViewController: PlanDetailsViewControllerDelegate {
   
    func didUpdateRebate(_ planDetailsViewController: PlanDetailsViewController, rebate: Rebate?) {
        self.rebate = rebate
    }
    
}

// MARK: - PulleyDrawerViewControllerDelegate

extension RebateViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return RebateAttribute.allValues.isEnabled ? 84 : 0
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return RebateAttribute.allValues.isEnabled ? (64 + (CGFloat(visibleRebateAttributes.count + 1) * 55) + 20) : 0
        // + 1 for the segmented control
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .partiallyRevealed]
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        if drawer.drawerPosition == .collapsed {
            isDrawerRevealed = false
        } else if drawer.drawerPosition == .partiallyRevealed {
            isDrawerRevealed = true
        }
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat) {
        pulleyDrawerDelegate?.rebateViewControllerDidChangeDistanceFromBottom(drawer: drawer, distance: distance, bottomSafeArea: bottomSafeArea)
    }
    
}

protocol RebateViewControllerDelegate: AnyObject {
    func rebateViewControllerDidSetDrawerPosition(_ rebateViewController: RebateViewController, position: PulleyPosition)
}

protocol RebateViewControllerPulleyDelegate: AnyObject {
    func rebateViewControllerDidChangeDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat, bottomSafeArea: CGFloat)
}
