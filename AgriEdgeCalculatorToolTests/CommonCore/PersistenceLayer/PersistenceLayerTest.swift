//
//  PersistenceLayerTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 6/17/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift
import XCTest
@testable import AgriEdgeCalculatorTool

class PersistenceLayerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        PersistenceLayer().emptyRealm()
        PersistenceLayer(configuration: .update).emptyRealm()
    }
    
    func testUpdateRealmExists() {
        let updatePersistenceController = PersistenceLayer(configuration: .update)
        updatePersistenceController.create(RealmObjectsTestData.newGrowerA)
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("update.realm") {
            XCTAssertTrue(FileManager.default.fileExists(atPath: pathComponent.path))
        } else {
            XCTFail("update.realm file does not exist")
        }
    }
    
    func testDefaultRealmExists() {
        PersistenceLayer().create(RealmObjectsTestData.newGrowerA)
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("default.realm") {
            XCTAssertTrue(FileManager.default.fileExists(atPath: pathComponent.path))
        } else {
            XCTFail("default.realm file does not exist")
        }
    }

    func testCreateSuccess() {
        PersistenceLayer().create(RealmObjectsTestData.newGrowerA) { result in
            switch result {
            case .success(let newGrower):
                XCTAssertNotNil(newGrower)
                let isCorrectType = type(of: newGrower) == GrowerObject.self
                XCTAssertTrue(isCorrectType)
                XCTAssertEqual(newGrower.firstName, RealmObjectsTestData.newGrowerA.firstName)
            case .failure(let error):
                XCTFail("expected a Grower but got error: \(error)")
            }
        }
    }
    
    func testSaveSuccess() {
        let expectation = self.expectation(description: "waiting for object to be saved")
        
        PersistenceLayer().save(RealmObjectsTestData.newGrowerA) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected a Grower but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            let predicate = NSPredicate(format: "firstName = %@", RealmObjectsTestData.newGrowerA.firstName ?? "")
            let expectedName = PersistenceLayer().fetch(GrowerObject.self, predicate: predicate)?.first?.firstName
            XCTAssertEqual(expectedName, "Matt")
        }
    }
    
    func testSaveAllSuccess() {
        let expectation = self.expectation(description: "waiting for objects to be saved")
        
        PersistenceLayer().saveAll(of: [RealmObjectsTestData.newGrowerA, RealmObjectsTestData.newGrowerB]) { result in
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
            XCTAssertEqual(growers?.last?.firstName, "Lloyd")
        }
    }
    
    func testCleanSaveAllSuccess() {
        let expectation = self.expectation(description: "waiting for objects to be cleaned and saved")

        PersistenceLayer().saveAll(of: [RealmObjectsTestData.newGrowerA, RealmObjectsTestData.newGrowerB])
        let growersToAdd: [GrowerObject] = [RealmObjectsTestData.newGrowerC]
        PersistenceLayer().cleanSaveAll(of: growersToAdd) { result in
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
        }
    }
    
    func testUpdateSuccess() {
        var persistedObject: GrowerObject?
        let expectation = self.expectation(description: "waiting for object to be updated")
        
        PersistenceLayer().save(RealmObjectsTestData.newGrowerA)
        
        let predicate = NSPredicate(format: "firstName = %@", RealmObjectsTestData.newGrowerA.firstName ?? "")
        let grower = PersistenceLayer().fetch(GrowerObject.self, predicate: predicate)?.first
        XCTAssertEqual(grower?.firstName, "Matt")
        persistedObject = grower

        guard let object = persistedObject else {
            XCTFail("expexted a non nil persisted object but got a nil object")
            return
        }
        
        PersistenceLayer().update(object, updates: { (grower: GrowerObject) in
            grower.firstName = "Mark"
            grower.lastName = "Lloyd"
        }, completion: { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected a Grower but got error: \(error)")
            }
        })
        
        waitForExpectations(timeout: 2.0) { _ in
            let predicate = NSPredicate(format: "firstName = %@", "Mark")

            let growers = PersistenceLayer().fetch(GrowerObject.self, predicate: predicate)
            XCTAssertEqual(growers?.first?.firstName, "Mark")
        }
    }
    
    func testDeleteSuccess() {
        var persistedObject: GrowerObject?
        let expectation = self.expectation(description: "waiting for object to be deleted")

        PersistenceLayer().save(RealmObjectsTestData.newGrowerA)
        
        let predicate = NSPredicate(format: "firstName = %@", RealmObjectsTestData.newGrowerA.firstName ?? "")
        let growers = PersistenceLayer().fetch(GrowerObject.self, predicate: predicate)
        XCTAssertEqual(growers?.first?.firstName, "Matt")
        persistedObject = growers?.first

        guard let object = persistedObject else {
            XCTFail("expexted a non nil persisted object but got a nil object")
            return
        }
        
        PersistenceLayer().delete(object) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected a Grower but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            let predicate = NSPredicate(format: "firstName = %@", RealmObjectsTestData.newGrowerA.firstName ?? "")
            let emptyGrowers = PersistenceLayer().fetch(GrowerObject.self, predicate: predicate)
            XCTAssertNil(emptyGrowers)
        }
    }
    
    func testDeleteAllSuccess() {
        let expectation = self.expectation(description: "waiting for objects to be deleted")
        
        PersistenceLayer().saveAll(of: [RealmObjectsTestData.newGrowerA, RealmObjectsTestData.newGrowerB])
        let growers = PersistenceLayer().fetch(GrowerObject.self)
        XCTAssertEqual(growers?.count, 2)
        
        PersistenceLayer().deleteAll(of: GrowerObject.self) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected to delete all Growers but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            let emptyGrowers = PersistenceLayer().fetch(GrowerObject.self)
            XCTAssertNil(emptyGrowers)
        }
    }
    
    func testEmptyRealmSuccess() {
        let expectation = self.expectation(description: "waiting for all objects to be deleted")
        
        PersistenceLayer().saveAll(of: [RealmObjectsTestData.newGrowerA, RealmObjectsTestData.newGrowerB, RealmObjectsTestData.newPlanA, RealmObjectsTestData.newPlanB])
        
        PersistenceLayer().emptyRealm { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected to empty realm but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertTrue(PersistenceLayer().isRealmEmpty)
        }
    }
    
    func testFetchSuccess() {
        let expectation = self.expectation(description: "waiting for object to be saved")
        
        PersistenceLayer().save(RealmObjectsTestData.newGrowerA) { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected a Grower but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            let predicate = NSPredicate(format: "firstName = %@", RealmObjectsTestData.newGrowerA.firstName ?? "")
            let growers = PersistenceLayer().fetch(GrowerObject.self, predicate: predicate)
            XCTAssertEqual(growers?.first?.firstName, "Matt")
        }
    }

}
