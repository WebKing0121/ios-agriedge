//
//  ApplicationDetailsViewControllerTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 7/8/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import XCTest
@testable import AgriEdgeCalculatorTool

class ApplicationDetailsViewControllerTest: XCTestCase {
    
    private lazy var applicationDetailsViewController: ApplicationDetailsViewController? = {
        let storyboard = UIStoryboard(name: "ApplicationDetails", bundle: nil)
        let applicationDetailsNavVC = storyboard.instantiateInitialViewController() as? UINavigationController
        return applicationDetailsNavVC?.topViewController as? ApplicationDetailsViewController
    }()
    
    override func setUp() {
        super.setUp()
        applicationDetailsViewController?.loadViewIfNeeded()
        applicationDetailsViewController?.tableView.reloadData()
        PersistenceLayer().emptyRealm()
    }
    
    override func tearDown() {
        applicationDetailsViewController = nil
    }
    
    func testTableViewNumberOfSections() {
        XCTAssertEqual(applicationDetailsViewController?.tableView.numberOfSections, 2)
    }
    
    func testTableViewTargetCropSection() {
        XCTAssertEqual(applicationDetailsViewController?.tableView.numberOfRows(inSection: ApplicationDetailsViewController.TableViewSection.targetCrop.rawValue), 1)
    }
    
    func testTableViewProductSection() {
        XCTAssertEqual(applicationDetailsViewController?.tableView.numberOfRows(inSection: ApplicationDetailsViewController.TableViewSection.product.rawValue), 1)
    }
    
    func testUseSameRateCell() {
        let cell = applicationDetailsViewController?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? LabeledToggleTableViewCell
        XCTAssertEqual(cell?.titleLabelText, nil)
    }
    
    func testSavePlanButton() {
        guard let saveApplicationButton = applicationDetailsViewController?.primaryButton else {
            XCTFail("couldn't find the saveApplicationButton")
            return
        }
        
        XCTAssertEqual(saveApplicationButton.title, "Save Application")
    }
    
}
