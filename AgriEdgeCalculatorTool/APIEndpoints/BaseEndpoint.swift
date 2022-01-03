//
//  BaseEndpoint.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/28/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya

protocol BaseEndpoint: TargetType, AccessTokenAuthorizable {
   
    var persist: (([Codable]) -> Void)? { get }
    
    var cleanPersist: (([Codable]) -> Void)? { get }
    
    var baseURL: URL { get }
    
    var authorizationType: AuthorizationType { get }

}

extension BaseEndpoint {
    
    var baseURL: URL {
        // PROD server
        return URL(string: "https://act-api.landdb.com/ae")!
        // DEV server
        //return URL(string: "https://act-api-dev.landdb.com/ae")!
    }
    
    var authorizationType: AuthorizationType {
        return .bearer
    }
    
    var persist: (([Codable]) -> Void)? {
        return nil
    }
    
    var cleanPersist: (([Codable]) -> Void)? {
        return nil
    }
    
}
