//
//  GrowersEndpointTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 6/21/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya
import XCTest
@testable import AgriEdgeCalculatorTool

class GrowersEndpointTest: XCTestCase {

    var endpointTarget: GrowersEndpoint!
    
    // MARK: GET and POST growers
    
    func testFetchGrowersEndpoint() {
        endpointTarget = GrowersEndpoint.fetchGrowers(userID: "user_id", persistCompletion: nil)
        XCTAssertEqual(endpointTarget.baseURL.absoluteString, "https://prod-api-agriedge-lb.syndpe.com/ae")
        XCTAssertEqual(endpointTarget.path, "/growers")
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
    
    func testCreateGrowerEndpoint() {
        let growerRequest = GrowersRequest(growers: [Grower(growerObject: RealmObjectsTestData.newGrowerA)])
        endpointTarget = GrowersEndpoint.createGrowers(userID: "user_id", growers: growerRequest)
        XCTAssertEqual(endpointTarget.baseURL.absoluteString, "https://prod-api-agriedge-lb.syndpe.com/ae")
        XCTAssertEqual(endpointTarget.path, "/growers")
        XCTAssertEqual(endpointTarget.method, .post)
        XCTAssertEqual(endpointTarget.headers, ["Content-Type": "application/json", "userID": "user_id"])

        switch endpointTarget.task {
        case .requestJSONEncodable:
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
    
    func testDeleteGrowerEndpoint() {
        let grower = Grower(growerObject: RealmObjectsTestData.newGrowerA)
        endpointTarget = GrowersEndpoint.deleteGrower(userID: "user_ID", growerID: grower.growerID)
        XCTAssertEqual(endpointTarget.baseURL.absoluteString, "https://prod-api-agriedge-lb.syndpe.com/ae")
        XCTAssertEqual(endpointTarget.path, "/grower/\(grower.growerID)")
        XCTAssertEqual(endpointTarget.method, .delete)
        XCTAssertEqual(endpointTarget.headers, ["Content-Type": "application/json", "userID": "user_ID"])
        
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
