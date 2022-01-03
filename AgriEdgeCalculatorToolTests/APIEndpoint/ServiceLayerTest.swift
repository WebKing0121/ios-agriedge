//
//  ServiceLayerTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 6/21/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya
import XCTest
@testable import AgriEdgeCalculatorTool

class ServiceLayerTest: XCTestCase {
    
    // MARK: Fetch Growers
    
    func testFetchGrowersSuccess() {
        let expectation = self.expectation(description: "waiting to fetch growers")
        var growers: [Grower]?
        
        ServiceLayer(stubClosure: MoyaProvider.immediatelyStub).fetch(GrowersEndpoint.fetchGrowers(userID: "user_id", persistCompletion: nil)) {
            (result: (ServiceResult<[Grower]>)) in
            
            switch result {
            case .success(let growersResult):
                growers = growersResult
                expectation.fulfill()
            case .failure(let error):
                XCTFail("expected to fetch growers but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertEqual(growers?.count, 2)
        }
    }
    
    func testFetchGrowersMappingFailure() {
        let expectation = self.expectation(description: "waiting to fetch growers")
        var errorMessage: String = ""
        
        let endpointClosure = { (target: GrowersEndpoint) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(200, FileReader.readDataFromJSONFile(filename: "EmptyResponse")) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        ServiceLayer(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub).fetch(GrowersEndpoint.fetchGrowers(userID: "user_id", persistCompletion: nil)) {
            (result: (ServiceResult<[Grower]>)) in
            
            switch result {
            case .success(let result):
                XCTFail("expected to fail mapping but got: \(result)")
            case .failure(let errorResponse):
                errorMessage = errorResponse
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(errorMessage.contains("error mapping data"))
        }
    }
    
    func testFetchGrowersServiceFailure() {
        let expectation = self.expectation(description: "waiting to fetch growers")
        var errorMessage: String = ""
        
        let endpointClosure = { (target: GrowersEndpoint) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkError(NSError(domain: "networkError", code: 500)) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        ServiceLayer(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub).fetch(GrowersEndpoint.fetchGrowers(userID: "user_id", persistCompletion: nil)) {
            (result: (ServiceResult<[Grower]>)) in
            
            switch result {
            case .success(let growersResult):
                XCTFail("expected to fail fetching growers but got: \(growersResult)")
            case .failure(let errorResponse):
                errorMessage = errorResponse
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(errorMessage.contains("failure fetching data"))
        }
    }
    
}
