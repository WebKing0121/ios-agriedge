//
//  LoginEndpoint.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 8/7/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya
import RealmSwift

enum LoginEndpoint {
    case healthcheck
    case login(userEmail: String)
}

extension LoginEndpoint: BaseEndpoint, AccessTokenAuthorizable {
    
    var path: String {
        switch self {
        case .healthcheck:
            return "/healthcheck"
        case .login:
            return "/login"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .healthcheck:
            return .get
        case .login:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .healthcheck:
            return .requestPlain
        case .login(let userEmail):
            return .requestParameters(parameters: ["email": "\(userEmail)"], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .healthcheck, .login:
            return ["Content-Type": "application/json"]
        }
    }
    
    var sampleData: Data {
        switch self {
        case .healthcheck:
            return FileReader.readDataFromJSONFile(filename: "GetHealthcheckResponse")
        case .login:
            return FileReader.readDataFromJSONFile(filename: "GetLoginResponse")
        }
    }
    
    var persist: (([Codable]) -> Void)? {
        switch self {
        case .healthcheck, .login:
            return nil
        }
    }
    
}
