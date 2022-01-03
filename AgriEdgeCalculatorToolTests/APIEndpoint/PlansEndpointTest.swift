//
//  PlansEndpointTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 7/24/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya
import XCTest
@testable import AgriEdgeCalculatorTool

class PlansEndpointTest: XCTestCase {
    
    var endpointTarget: PlansEndpoint!
    
    // MARK: GET, POST, DELETE plans
    
    func testFetchPlansEndpoint() {
        endpointTarget = PlansEndpoint.fetchPlans(persistCompletion: nil)
        XCTAssertEqual(endpointTarget.baseURL.absoluteString, "https://prod-api-agriedge-lb.syndpe.com/ae")
        XCTAssertEqual(endpointTarget.path, "/plans")
        XCTAssertEqual(endpointTarget.method, .get)
        XCTAssertEqual(endpointTarget.headers, ["Content-Type": "application/json"])
        
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
    
    func testCreatePlansEndpoint() {
        let plan = Plan(planObject: RealmObjectsTestData.newPlanA)
        endpointTarget = PlansEndpoint.createPlan(plan: plan)
        XCTAssertEqual(endpointTarget.baseURL.absoluteString, "https://prod-api-agriedge-lb.syndpe.com/ae")
        XCTAssertEqual(endpointTarget.path, "/plan")
        XCTAssertEqual(endpointTarget.method, .post)
        XCTAssertEqual(endpointTarget.headers, ["Content-Type": "application/json"])
        
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
    
    func testDeletePlansEndpoint() {
        let plan = Plan(planObject: RealmObjectsTestData.newPlanA)
        endpointTarget = PlansEndpoint.deletePlan(planID: plan.planID, userID: "user_ID")
        XCTAssertEqual(endpointTarget.baseURL.absoluteString, "https://prod-api-agriedge-lb.syndpe.com/ae")
        XCTAssertEqual(endpointTarget.path, "/plan/\(plan.planID)")
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
