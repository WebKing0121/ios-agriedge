//
//  DualPersistenceLayerTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 6/20/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift
import XCTest
@testable import AgriEdgeCalculatorTool

class DualPersistenceLayerTest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        PersistenceLayer().emptyRealm()
        PersistenceLayer(configuration: .update).emptyRealm()
    }
    
    func testSaveSuccess() {
        let expectation = self.expectation(description: "waiting for object to be saved")
        
        DualPersistenceLayer(shouldAddToUpdateRealm: true).save(RealmObjectsTestData.newGrowerA) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected a Grower but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            let predicate = NSPredicate(format: "firstName = %@", RealmObjectsTestData.newGrowerA.firstName ?? "")
            let expectedName = DualPersistenceLayer().fetch(GrowerObject.self, predicate: predicate)?.first?.firstName
            XCTAssertEqual(expectedName, "Matt")
            
            let expectedNameFromUpdateRealm = DualPersistenceLayer(configuration: .update).fetch(GrowerObject.self, predicate: predicate)?.first?.firstName
            XCTAssertEqual(expectedNameFromUpdateRealm, "Matt")
        }
    }
    
    func testSaveAllSuccess() {
        let expectation = self.expectation(description: "waiting for object to be saved")
        
        DualPersistenceLayer(shouldAddToUpdateRealm: true).saveAll(of: [RealmObjectsTestData.newGrowerA, RealmObjectsTestData.newGrowerB]) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected a Grower but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            let growers = PersistenceLayer().fetch(GrowerObject.self)
            XCTAssertEqual(growers?.count, 2)
            XCTAssertEqual(growers?.first?.firstName, "Matt")

            let growersFromUpdateRealm = PersistenceLayer(configuration: .update).fetch(GrowerObject.self)
            XCTAssertEqual(growersFromUpdateRealm?.count, 2)
            XCTAssertEqual(growersFromUpdateRealm?.first?.firstName, "Matt")
        }
    }
    
    func testCleanSaveAllSuccess() {
        let expectation = self.expectation(description: "waiting for object to be saved")
        
        PersistenceLayer().saveAll(of: [RealmObjectsTestData.newGrowerA, RealmObjectsTestData.newGrowerB])

        DualPersistenceLayer(shouldAddToUpdateRealm: true).cleanSaveAll(of: [RealmObjectsTestData.newGrowerC]) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected a Grower but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            let growers = PersistenceLayer().fetch(GrowerObject.self)
            XCTAssertEqual(growers?.count, 1)
            XCTAssertEqual(growers?.first?.firstName, "Brett")
            
            let growersFromUpdateRealm = PersistenceLayer(configuration: .update).fetch(GrowerObject.self)
            XCTAssertEqual(growersFromUpdateRealm?.count, 1)
            XCTAssertEqual(growersFromUpdateRealm?.first?.firstName, "Brett")
        }
    }
    
}
