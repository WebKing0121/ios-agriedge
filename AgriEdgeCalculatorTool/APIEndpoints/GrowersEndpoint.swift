//
//  GrowersEndpoint.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/20/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya

enum GrowersEndpoint {
    case fetchGrowers(userID: String, persistCompletion: (() -> Void)?)
    case createGrowers(userID: String, growers: GrowersRequest)
    case deleteGrower(userID: String, growerID: String)
}

extension GrowersEndpoint: BaseEndpoint {
        
    var path: String {
        switch self {
        case .fetchGrowers, .createGrowers:
            return "/growers"
        case .deleteGrower(_, let growerID):
            return "/grower/\(growerID)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchGrowers:
            return .get
        case .createGrowers:
            return .post
        case .deleteGrower:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .fetchGrowers, .deleteGrower:
            return .requestPlain
        case .createGrowers(_, let growers):
            return .requestJSONEncodable(growers)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .fetchGrowers(let userID, _), .createGrowers(let userID, _):
            return ["Content-Type": "application/json", "userID": "\(userID)"]
        case .deleteGrower(let userID, _):
            return ["Content-Type": "application/json", "userID": "\(userID)"]
        }
    }
    
    var sampleData: Data {
        switch self {
        case .fetchGrowers:
            return FileReader.readDataFromJSONFile(filename: "GetGrowersResponse")
        case .createGrowers, .deleteGrower:
            return Data()
        }
    }
    
    var persist: (([Codable]) -> Void)? {
        switch self {
        case .fetchGrowers(_, let completion):
            return { growers in
                guard let growers = growers as? [Grower] else { return }

                let growerObjects = growers.map({
                    (grower: Grower) -> GrowerObject in
                    return GrowerObject().project(from: grower, shouldCleanPlans: true)
                })

                DualPersistenceLayer().saveAll(of: growerObjects) { result in
                    switch result {
                    case .success:
                        completion?()
                        log(info: "saved \(growerObjects.count) grower objects to Realm")
                    case .failure:
                        log(error: "Error Saving Grower")
                    }
                }
            }
        case .createGrowers, .deleteGrower:
            return nil
        }
    }
    
    var cleanPersist: (([Codable]) -> Void)? {
        switch self {
        case .fetchGrowers(_, let completion):
            return { growers in
                guard let growers = growers as? [Grower] else { return }
                
                let growerObjects = growers.map({
                    (grower: Grower) -> GrowerObject in
                    return GrowerObject().project(from: grower, shouldCleanPlans: true)
                })
                DualPersistenceLayer().cleanSaveAll(of: growerObjects) { result in
                    switch result {
                    case .success:
                        completion?()
                        log(info: "saved \(growerObjects.count) grower objects to Realm")
                    case .failure:
                        log(error: "Error Saving Grower")
                    }
                }
            }
        case .createGrowers, .deleteGrower:
            return nil
        }
    }
}
