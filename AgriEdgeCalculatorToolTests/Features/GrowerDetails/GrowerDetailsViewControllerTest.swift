//
//  GrowerDetailsViewControllerTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 6/17/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import XCTest
@testable import AgriEdgeCalculatorTool

class GrowerDetailsViewControllerTest: XCTestCase {
    
    private lazy var growersDetailsViewController: GrowerDetailsViewController? = {
        let storyboard = UIStoryboard(name: "GrowerDetails", bundle: nil)
        let growersListNavVC = storyboard.instantiateInitialViewController() as? UINavigationController
        return growersListNavVC?.topViewController as? GrowerDetailsViewController
    }()
    
    override func setUp() {
        super.setUp()
        growersDetailsViewController?.loadViewIfNeeded()
        growersDetailsViewController?.tableView.reloadData()
        PersistenceLayer().emptyRealm()
    }
    
    override func tearDown() {
        growersDetailsViewController = nil
    }
    
    func testTableViewNumberOfSections() {
        XCTAssertEqual(growersDetailsViewController?.tableView.numberOfSections, 3)
    }
    
    func testTableViewGrowerNameSection() {
        XCTAssertEqual(growersDetailsViewController?.tableView.numberOfRows(inSection: GrowerDetailsViewController.TableViewSection.growerName.rawValue), 2)
    }
    
    func testTableViewGrowerInfoSection() {
        XCTAssertEqual(growersDetailsViewController?.tableView.numberOfRows(inSection: GrowerDetailsViewController.TableViewSection.growerInfo.rawValue), 4)
    }
    
    func testFarmNameCell() {
        let indexPath = IndexPath(item: 0, section: GrowerDetailsViewController.TableViewSection.growerName.rawValue)
        growersDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)

        guard let cell = growersDetailsViewController?.tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        XCTAssertEqual(cell.titleLabelText, "Farm Name")
        XCTAssertEqual(cell.textFieldPlaceholder, "farm name")
    }
    
    func testZoneCell() {
        let indexPath = IndexPath(item: 1, section: GrowerDetailsViewController.TableViewSection.growerName.rawValue)
        growersDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)

        guard let cell = growersDetailsViewController?.tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        XCTAssertEqual(cell.titleLabelText, "AgriEdge Zone")
        XCTAssertEqual(cell.textFieldPlaceholder, "zone")
    }
    
    func testFirstNameCell() {
        let indexPath = IndexPath(item: 0, section: GrowerDetailsViewController.TableViewSection.growerInfo.rawValue)
        growersDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)

        guard let cell = growersDetailsViewController?.tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        XCTAssertEqual(cell.titleLabelText, "First Name (optional)")
        XCTAssertEqual(cell.textFieldPlaceholder, "first name")
    }
    
    func testLastNameCell() {
        let indexPath = IndexPath(item: 1, section: GrowerDetailsViewController.TableViewSection.growerInfo.rawValue)
        growersDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)

        guard let cell = growersDetailsViewController?.tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        XCTAssertEqual(cell.titleLabelText, "Last Name (optional)")
        XCTAssertEqual(cell.textFieldPlaceholder, "last name")
    }
    
    func testEmailCell() {
        let indexPath = IndexPath(item: 2, section: GrowerDetailsViewController.TableViewSection.growerInfo.rawValue)
        growersDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)

        guard let cell = growersDetailsViewController?.tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        XCTAssertEqual(cell.titleLabelText, "Email (optional)")
        XCTAssertEqual(cell.textFieldPlaceholder, "email")
        XCTAssertEqual(cell.textFieldContentType, .emailAddress)
        XCTAssertEqual(cell.textFieldKeyboardType, .emailAddress)
    }

    func testPhoneNumberCell() {
        let indexPath = IndexPath(item: 3, section: GrowerDetailsViewController.TableViewSection.growerInfo.rawValue)
        growersDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)

        guard let cell = growersDetailsViewController?.tableView.cellForRow(at: indexPath) as? LabeledTextFieldTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        
        XCTAssertEqual(cell.titleLabelText, "Phone (optional)")
        XCTAssertEqual(cell.textFieldPlaceholder, "(123) 456-7890")
        XCTAssertEqual(cell.textFieldContentType, .telephoneNumber)
        XCTAssertEqual(cell.textFieldKeyboardType, .phonePad)
    }
    
    func testCropSectionEmptyCell() {
        let indexPath = IndexPath(item: 0, section: GrowerDetailsViewController.TableViewSection.cropInfo.rawValue)
        growersDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        
        guard let cell = growersDetailsViewController?.tableView.cellForRow(at: indexPath) as? InfoLabelTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        
        XCTAssertEqual(cell.infoLabelText, "Please select a zone first.")
        XCTAssertFalse(cell.isUserInteractionEnabled)
    }
    
    func testCropCell() {
        let newCrop = Crop(cropObject: RealmObjectsTestData.newCropA)
        let searchTableViewController = SearchTableViewController<Crop>(title: "Crop List", dataSource: [newCrop])
        growersDetailsViewController?.didSelectItem(searchTableViewController, item: newCrop)
        let indexPath = IndexPath(item: 0, section: GrowerDetailsViewController.TableViewSection.cropInfo.rawValue)
        growersDetailsViewController?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        
        guard let cell = growersDetailsViewController?.tableView.cellForRow(at: indexPath) as? LabeledTextFieldAccessoryTableViewCell else {
            XCTFail("couldn't find cell")
            return
        }
        
        XCTAssertEqual(cell.titleLabelText, newCrop.cropID.cropNameFromID())
        XCTAssertEqual(cell.textFieldPlaceholder, "0")
    }
    
    func testSaveGrowerButton() {
        guard let saveGrowerButton = growersDetailsViewController?.primaryButton else {
            XCTFail("couldn't find the saveGrowerButton")
            return
        }
        
        XCTAssertEqual(saveGrowerButton.title, "Save and Close")
    }
    
}
