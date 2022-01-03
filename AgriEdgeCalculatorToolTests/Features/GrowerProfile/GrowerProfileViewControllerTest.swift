//
//  GrowerProfileViewControllerTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 7/8/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import XCTest
@testable import AgriEdgeCalculatorTool

class GrowerProfileViewControllerTest: XCTestCase {
    
    private lazy var growerProfileViewController: GrowerProfileViewController? = {
        let storyboard = UIStoryboard(name: "GrowerProfile", bundle: nil)
        return storyboard.instantiateInitialViewController() as? GrowerProfileViewController
    }()
    
    override func setUp() {
        super.setUp()
        growerProfileViewController?.grower = Grower(growerObject: RealmObjectsTestData.newGrowerA)
        growerProfileViewController?.loadViewIfNeeded()
        growerProfileViewController?.tableView.reloadData()
        PersistenceLayer().emptyRealm()
    }
    
    override func tearDown() {
        growerProfileViewController = nil
    }
    
    func testTableViewNumberOfSections() {
        XCTAssertEqual(growerProfileViewController?.tableView.numberOfSections, 2)
    }
    
    func testTableViewCropsSection() {
        XCTAssertEqual(growerProfileViewController?.tableView.numberOfRows(inSection: GrowerProfileViewController.TableViewSection.crops.rawValue), growerProfileViewController?.grower?.crops?.count)
    }
    
    func testTableViewPlansSection() {
        XCTAssertEqual(growerProfileViewController?.tableView.numberOfRows(inSection: GrowerProfileViewController.TableViewSection.plans.rawValue), 1)
    }
    
    func testCropCell() {
        PersistenceLayer().save(RealmObjectsTestData.newCropA)
        
        let indexPath = IndexPath(item: 0, section: GrowerProfileViewController.TableViewSection.crops.rawValue)
        growerProfileViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)

        guard let cell = growerProfileViewController?.tableView.cellForRow(at: indexPath) as? LabeledTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        XCTAssertEqual(cell.titleLabelText, "Cucumber")
        XCTAssertEqual(cell.accessoryLabelText, "1100 acres")
    }

    func testEmptyPlansCell() {
        let indexPath = IndexPath(item: 0, section: GrowerProfileViewController.TableViewSection.plans.rawValue)
        growerProfileViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)

        guard let cell = growerProfileViewController?.tableView.cellForRow(at: indexPath) as? InfoLabelTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        XCTAssertEqual(cell.infoLabelText, "No plans created.")
        XCTAssertFalse(cell.isUserInteractionEnabled)
    }

}
