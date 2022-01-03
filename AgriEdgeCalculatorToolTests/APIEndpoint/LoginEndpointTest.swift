//
//  LoginEndpointTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 10/17/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya
import XCTest
@testable import AgriEdgeCalculatorTool

class LoginEndpointTest: XCTestCase {
    
    var endpointTarget: LoginEndpoint!
    
    // MARK: GET Healthcheck
    
    func testHealthCheckEndpoint() {
        endpointTarget = LoginEndpoint.healthcheck
        XCTAssertEqual(endpointTarget.baseURL.absoluteString, "https://prod-api-agriedge-lb.syndpe.com/ae")
        XCTAssertEqual(endpointTarget.path, "/healthcheck")
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
    
    // MARK: GET login
    
    func testLoginEndpoint() {
        endpointTarget = LoginEndpoint.login(userEmail: "email@email.com")
        XCTAssertEqual(endpointTarget.baseURL.absoluteString, "https://prod-api-agriedge-lb.syndpe.com/ae")
        XCTAssertEqual(endpointTarget.path, "/login")
        XCTAssertEqual(endpointTarget.method, .post)
        XCTAssertEqual(endpointTarget.headers, ["Content-Type": "application/json"])
        
        switch endpointTarget.task {
        case .requestParameters(let parameters, _):
            let parameterValue = parameters["email"] as? String
            XCTAssertEqual(parameterValue, "email@email.com")
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
