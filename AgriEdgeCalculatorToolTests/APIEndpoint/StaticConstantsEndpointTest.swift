//
//  StaticConstantsEndpointTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 6/27/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya
import XCTest
@testable import AgriEdgeCalculatorTool

class StaticConstantsEndpointTest: XCTestCase {
    
    var endpointTarget: StaticDataEndpoint!
    
    // MARK: GET static data
    
    func testFetchZonesEndpoint() {
        endpointTarget = StaticDataEndpoint.fetchStaticData(userID: "user_id")
        XCTAssertEqual(endpointTarget.baseURL.absoluteString, "https://prod-api-agriedge-lb.syndpe.com/ae")
        XCTAssertEqual(endpointTarget.path, "/staticData")
        XCTAssertEqual(endpointTarget.method, .get)
        XCTAssertEqual(endpointTarget.headers, ["Content-Type": "application/json", "userID": "user_id"])
        
        switch endpointTarget.task {
        case .requestPlain:
            break
        default:
            XCTFail("expected requestPlain task but got something else")
        }
        
        switch endpointTarget.authorizationType {
        case .bearer:
            break
        default:
            XCTFail("expected bearer authorizationType but got something else")
        }
    }
    
}
