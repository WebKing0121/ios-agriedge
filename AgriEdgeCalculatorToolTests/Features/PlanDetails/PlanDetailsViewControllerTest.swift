//
//  PlanDetailsViewControllerTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 7/8/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Pulley
import XCTest
@testable import AgriEdgeCalculatorTool

class PlanDetailsViewControllerTest: XCTestCase {
    
    private lazy var planDetailsViewController: PlanDetailsViewController? = {
        let storyboard = UIStoryboard(name: "PlanDetails", bundle: nil)
        let pulleyVC = storyboard.instantiateInitialViewController() as? PulleyViewController
        pulleyVC?.loadViewIfNeeded()
        return pulleyVC?.primaryContentViewController as? PlanDetailsViewController
    }()
    
    override func setUp() {
        super.setUp()
        planDetailsViewController?.loadViewIfNeeded()
        planDetailsViewController?.tableView.reloadData()
        PersistenceLayer().emptyRealm()
    }
    
    override func tearDown() {
        planDetailsViewController = nil
    }
    
    func testTableViewNumberOfSections() {
        XCTAssertEqual(planDetailsViewController?.tableView.numberOfSections, 2)
    }
    
    func testTableViewPlanNameSection() {
        XCTAssertEqual(planDetailsViewController?.tableView.numberOfRows(inSection: PlanDetailsViewController.TableViewSection.planProperties.rawValue), 1)
    }
    
    func testTableViewApplicationsSection() {
        XCTAssertEqual(planDetailsViewController?.tableView.numberOfRows(inSection: PlanDetailsViewController.TableViewSection.applications.rawValue), 1)
    }
    
    func testPlanNameCell() {
        let indexPath = IndexPath(item: 0, section: PlanDetailsViewController.TableViewSection.planProperties.rawValue)
        planDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)

        guard let cell = planDetailsViewController?.tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        XCTAssertNil(cell.titleLabelText)
    }
    
    func testApplicationsEmptyCell() {
        let indexPath = IndexPath(item: 0, section: PlanDetailsViewController.TableViewSection.applications.rawValue)
        planDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        
        guard let cell = planDetailsViewController?.tableView.cellForRow(at: indexPath) as? InfoLabelTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        
        XCTAssertEqual(cell.infoLabelText, "No applications yet.\nAdd an application to calculate a reward.")
        XCTAssertFalse(cell.isUserInteractionEnabled)
    }
    
    func testSavePlanButton() {
        guard let savePlanButton = planDetailsViewController?.primaryButton else {
            XCTFail("couldn't find the savePlanButton")
            return
        }
        
        XCTAssertEqual(savePlanButton.title, "Save and Close")
    }
        
}

extension PlanDetailsViewController {
    
    var savePlanButton: StyledButton? {
        return view.viewWithTag(1) as? StyledButton
    }
    
}
