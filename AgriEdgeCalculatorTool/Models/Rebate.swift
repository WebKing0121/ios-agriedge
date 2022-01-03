//
//  Rebate.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Foundation
import RealmSwift

struct Rebate: Codable {
    var rebateID = ""
    // CropProtection properties
    var estimatedRebateTotal = ""
    var tenNinetyCropsurance = ""
    var fiftyFiftyTarget = ""
    var capRiskManagement = ""
    var estimatedSpend = ""
    var estimatedSpendPerAcre = ""
    // Seed properties
    var seedEstimatedRebateTotal = ""
    var seedFiveNinetyFiveCropsurance = ""
    var seedTwentyEightyTarget = ""
    var seedCapRiskManagement = ""
    var seedEstimatedSpend = ""
    var seedEstimatedSpendPerAcre = ""
    // AgriClime
    var agriClimeCost: String? = ""
    // Total (CP + Seed) - agriClimeCost
    var totalEstimatedRebateTotal = ""
    
    enum CodingKeys: String, CodingKey {
        case rebateID
        case estimatedRebateTotal
        case tenNinetyCropsurance
        case fiftyFiftyTarget
        case capRiskManagement
        case estimatedSpend
        case estimatedSpendPerAcre
        case seedEstimatedRebateTotal
        case seedFiveNinetyFiveCropsurance = "seedTenNinetyCropsurance"
        case seedTwentyEightyTarget = "seedFiftyFiftyTarget"
        case seedCapRiskManagement
        case seedEstimatedSpend
        case seedEstimatedSpendPerAcre
        case agriClimeCost
        case totalEstimatedRebateTotal
    }
    
    // MARK: Init Functions
    
    init(rebateID: String = UUID().uuidString,
         cpEstimatedRebateTotal: String = "",
         cpTenNinetyCropsurance: String = "",
         cpFiftyFiftyTarget: String = "",
         cpCapRiskManagement: String = "",
         cpEstimatedSpend: String = "",
         cpEstimatedSpendPerAcre: String = "",
         seedEstimatedRebateTotal: String = "",
         seedFiveNinetyFiveCropsurance: String = "",
         seedTwentyEightyTarget: String = "",
         seedCapRiskManagement: String = "",
         seedEstimatedSpend: String = "",
         seedEstimatedSpendPerAcre: String = "",
         agriClimeCost: String? = "",
         totalEstimatedRebateTotal: String = "") {
        self.rebateID = rebateID
        self.estimatedRebateTotal = cpEstimatedRebateTotal
        self.tenNinetyCropsurance = cpTenNinetyCropsurance
        self.fiftyFiftyTarget = cpFiftyFiftyTarget
        self.capRiskManagement = cpCapRiskManagement
        self.estimatedSpend = cpEstimatedSpend
        self.estimatedSpendPerAcre = cpEstimatedSpendPerAcre
        self.seedEstimatedRebateTotal = seedEstimatedRebateTotal
        self.seedFiveNinetyFiveCropsurance = seedFiveNinetyFiveCropsurance
        self.seedTwentyEightyTarget = seedTwentyEightyTarget
        self.seedCapRiskManagement = seedCapRiskManagement
        self.seedEstimatedSpend = seedEstimatedSpend
        self.seedEstimatedSpendPerAcre = seedEstimatedSpendPerAcre
        self.agriClimeCost = agriClimeCost
        self.totalEstimatedRebateTotal = totalEstimatedRebateTotal
    }
    
    init(rebateObject: RebateObject) {
        self.rebateID = rebateObject.rebateID
        self.estimatedRebateTotal = rebateObject.estimatedRebateTotal
        self.tenNinetyCropsurance = rebateObject.tenNinetyCropsurance
        self.fiftyFiftyTarget = rebateObject.fiftyFiftyTarget
        self.capRiskManagement = rebateObject.capRiskManagement
        self.estimatedSpend = rebateObject.estimatedSpend
        self.estimatedSpendPerAcre = rebateObject.estimatedSpendPerAcre
        self.seedEstimatedRebateTotal = rebateObject.seedEstimatedRebateTotal
        self.seedFiveNinetyFiveCropsurance = rebateObject.seedFiveNinetyFiveCropsurance
        self.seedTwentyEightyTarget = rebateObject.seedTwentyEightyTarget
        self.seedCapRiskManagement = rebateObject.seedCapRiskManagement
        self.seedEstimatedSpend = rebateObject.seedEstimatedSpend
        self.seedEstimatedSpendPerAcre = rebateObject.seedEstimatedSpendPerAcre
        self.agriClimeCost = rebateObject.agriClimeCost
        self.totalEstimatedRebateTotal = rebateObject.totalEstimatedRebateTotal
    }
        
}

@objcMembers
class RebateObject: Object {
    dynamic var rebateID = ""
    // CropProtection properties
    dynamic var estimatedRebateTotal = ""
    dynamic var tenNinetyCropsurance = ""
    dynamic var fiftyFiftyTarget = ""
    dynamic var capRiskManagement = ""
    dynamic var estimatedSpend = ""
    dynamic var estimatedSpendPerAcre = ""
    // Seed properties
    dynamic var seedEstimatedRebateTotal = ""
    dynamic var seedFiveNinetyFiveCropsurance = ""
    dynamic var seedTwentyEightyTarget = ""
    dynamic var seedCapRiskManagement = ""
    dynamic var seedEstimatedSpend = ""
    dynamic var seedEstimatedSpendPerAcre = ""
    // AgriClime
    dynamic var agriClimeCost: String? = ""
    // Total (CP + Seed) - agriClimeCost
    dynamic var totalEstimatedRebateTotal = ""

    func project(from rebate: Rebate) -> Self {
        self.rebateID = rebate.rebateID
        self.estimatedRebateTotal = rebate.estimatedRebateTotal
        self.tenNinetyCropsurance = rebate.tenNinetyCropsurance
        self.fiftyFiftyTarget = rebate.fiftyFiftyTarget
        self.capRiskManagement = rebate.capRiskManagement
        self.estimatedSpend = rebate.estimatedSpend
        self.estimatedSpendPerAcre = rebate.estimatedSpendPerAcre
        self.seedEstimatedRebateTotal = rebate.seedEstimatedRebateTotal
        self.seedFiveNinetyFiveCropsurance = rebate.seedFiveNinetyFiveCropsurance
        self.seedTwentyEightyTarget = rebate.seedTwentyEightyTarget
        self.seedCapRiskManagement = rebate.seedCapRiskManagement
        self.seedEstimatedSpend = rebate.seedEstimatedSpend
        self.seedEstimatedSpendPerAcre = rebate.seedEstimatedSpendPerAcre
        self.agriClimeCost = rebate.agriClimeCost
        self.totalEstimatedRebateTotal = rebate.totalEstimatedRebateTotal
        return self
    }
    
    override static func primaryKey() -> String? {
        return "rebateID"
    }
}
