//
//  GrowersListViewControllerTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 6/14/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import XCTest
@testable import AgriEdgeCalculatorTool

class GrowersListViewControllerTest: XCTestCase {
    
    private lazy var growersListViewController: GrowersListViewController? = {
        let storyboard = UIStoryboard(name: "GrowersList", bundle: nil)
        let growersListNavVC = storyboard.instantiateInitialViewController() as? UINavigationController
        return growersListNavVC?.topViewController as? GrowersListViewController
    }()

    override func setUp() {
        growersListViewController?.loadViewIfNeeded()
        growersListViewController?.tableView.reloadData()
    }

    override func tearDown() {
        growersListViewController = nil
    }
    
    func testTableViewEmptyState() {
        growersListViewController?.growersDataSource = []
        XCTAssertEqual(growersListViewController?.tableView.numberOfSections, 2)
        XCTAssertEqual(growersListViewController?.tableView.numberOfRows(inSection: 0), 0)
    }
    
    func testTableViewPopulatedState() {
        growersListViewController?.growersDataSource = RealmObjectsTestData.testGrowers.map({
            (growerObject: GrowerObject) -> Grower in
            return Grower(growerObject: growerObject)
        })
        XCTAssertEqual(growersListViewController?.tableView.numberOfSections, 2)
        XCTAssertEqual(growersListViewController?.tableView.numberOfRows(inSection: 0), RealmObjectsTestData.testGrowers.count - 1)
    }
    
}
