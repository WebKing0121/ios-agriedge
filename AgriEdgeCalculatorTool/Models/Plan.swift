//
//  Plan.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct Plan: Codable {
    var planID = ""
    var cropYear = ""
    var displayName = ""
    var planConfidence = PlanConfidence.default
    var isPriority = 0
    var growerID = ""
    var rebate = Rebate()
    var applications = [Application]()
    var seedApplications = [SeedApplication]()
    
    var isPriorityBool: Bool {
        return !(isPriority == 0)
    }
    
    init(planObject: PlanObject) {
        self.planID = planObject.planID
        self.cropYear = planObject.cropYear
        self.growerID = planObject.growerID
        self.displayName = planObject.displayName
        self.planConfidence = planObject.planConfidenceEnum
        self.isPriority = planObject.isPriority ? 1 : 0
        self.rebate = Rebate(rebateObject: planObject.rebate ?? RebateObject())
        self.applications = Array(planObject.applications).map({ Application(applicationObject: $0) })
        self.seedApplications = Array(planObject.seedApplications).map({ SeedApplication(seedApplicationObject: $0) })
    }
    
    init() {
        // NMTODO: need to set the crop year to the current crop year that will come from the server.
        planID = UUID().uuidString
    }
}

@objcMembers
class PlanObject: Object {
    dynamic var planID = ""
    dynamic var cropYear = ""
    dynamic var growerID = ""
    dynamic var displayName = ""
    @objc private dynamic var planConfidence: Int = PlanConfidence.default.rawValue
    var planConfidenceEnum: PlanConfidence {
        get { return PlanConfidence(rawValue: planConfidence) ?? .default }
        set { planConfidence = newValue.rawValue }
    }
    dynamic var isPriority = false
    dynamic var shouldDelete = false
    dynamic var rebate: RebateObject?
    var applications = List<ApplicationObject>()
    var seedApplications = List<SeedApplicationObject>()
    
    func project(from plan: Plan) -> Self {
        self.planID = plan.planID
        self.cropYear = plan.cropYear
        self.growerID = plan.growerID
        self.displayName = plan.displayName
        self.planConfidence = plan.planConfidence.rawValue
        self.isPriority = plan.isPriorityBool
        self.shouldDelete = false
        self.rebate = RebateObject().project(from: plan.rebate)
        plan.applications.forEach { application in
            self.applications.append(ApplicationObject().project(from: application))
        }
        plan.seedApplications.forEach { seedApplication in
            self.seedApplications.append(SeedApplicationObject().project(from: seedApplication))
        }
        return self
    }
    
    override static func primaryKey() -> String? {
        return "planID"
    }
    
    static public var isPriorityKeyPath: String { return #keyPath(isPriority) }
}
