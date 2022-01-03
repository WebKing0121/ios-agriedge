//
//  PlansEndpoint.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/23/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya

enum PlansEndpoint {
    case fetchPlans(persistCompletion: (() -> Void)?)
    case createPlan(plan: Plan)
    case deletePlan(planID: String, userID: String)
}

extension PlansEndpoint: BaseEndpoint, AccessTokenAuthorizable {
        
    var path: String {
        switch self {
        case .fetchPlans:
            return "/plans"
        case .createPlan:
            return "/plan"
        case .deletePlan(let planID, _):
            return "/plan/\(planID)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchPlans:
            return .get
        case .createPlan:
            return .post
        case .deletePlan:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .fetchPlans, .deletePlan:
            return .requestPlain
        case .createPlan(let plan):
            return .requestJSONEncodable(plan)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .fetchPlans,
             .createPlan:
            return ["Content-Type": "application/json"]
        case .deletePlan(_, let userID):
            return ["Content-Type": "application/json", "userID": "\(userID)"]
        }
    }
    
    var sampleData: Data {
        switch self {
        case .fetchPlans:
            return FileReader.readDataFromJSONFile(filename: "GetPlansResponse")
        case .createPlan, .deletePlan:
            return Data()
        }
    }
        
    var persist: (([Codable]) -> Void)? {
        switch self {
        case .fetchPlans(let completion):
            return { plans in
                guard let plans = plans as? [Plan] else { return }
                
                let planObjects = plans.map({
                    (plan: Plan) -> PlanObject in
                    return PlanObject().project(from: plan)
                })
                
                DualPersistenceLayer().saveAll(of: planObjects) { result in
                    switch result {
                    case .success:
                        completion?()
                        log(info: "saved \(planObjects.count) plan objects to Realm")
                    case .failure:
                        log(error: "error saving plan")
                    }
                }
            }
        case .createPlan, .deletePlan:
            return nil
        }
    }
    
}
