//
//  RebateAttribute.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/23/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Foundation

enum RebateAttribute: String, CaseIterable {
    case allValues
    case costShareRebateTotal
    case costShare
    case agriClimeCost
    case tenNinetyCropsurance
    case fiftyFiftyTarget
    case capRiskManagement
    case estimatedSpendPerAcre
    case estimatedSpend
    
    var genericTitle: String {
        switch self {
        case .allValues:
            return "Show Calculation Sheet"
        case .costShareRebateTotal:
            return "Total Cost-Share Opportunity"
        case .costShare:
            return "Cost-Share Opportunity"
        case .agriClimeCost:
            return "AgriClime Cost"
        case .tenNinetyCropsurance:
            return "Cropsurance"
        case .fiftyFiftyTarget:
            return "Target"
        case .capRiskManagement:
            return "CAP"
        case .estimatedSpendPerAcre:
            return "Estimated Spend/Acre"
        case .estimatedSpend:
            return "Estimated Spend"
        }
    }
    
    var cpTitle: String {
        switch self {
        case .allValues:
            return genericTitle
        case .costShareRebateTotal:
            return genericTitle
        case .costShare:
            return genericTitle
        case .agriClimeCost:
            return genericTitle
        case .tenNinetyCropsurance:
            return "10/90 Cropsurance"
        case .fiftyFiftyTarget:
            return "50/50 Target"
        case .capRiskManagement:
            return genericTitle
        case .estimatedSpendPerAcre:
            return genericTitle
        case .estimatedSpend:
            return genericTitle
        }
    }
    
    var seedTitle: String {
        switch self {
        case .allValues:
            return genericTitle
        case .costShareRebateTotal:
            return genericTitle
        case .costShare:
            return genericTitle
        case .agriClimeCost:
            return genericTitle
        case .tenNinetyCropsurance:
            return "5/95 Cropsurance"
        case .fiftyFiftyTarget:
            return "20/80 Target"
        case .capRiskManagement:
            return genericTitle
        case .estimatedSpendPerAcre:
            return genericTitle
        case .estimatedSpend:
            return genericTitle
        }
    }
    
    /// IndexPath for the Settings screen
    var indexPath: IndexPath {
        switch self {
        case .allValues:
            return IndexPath(row: 0, section: 0)
        case .costShareRebateTotal:
            return IndexPath(row: 1, section: 0)
        case .costShare:
            return IndexPath(row: 2, section: 0)
        case .agriClimeCost:
            return IndexPath(row: 3, section: 0)
        case .tenNinetyCropsurance:
            return IndexPath(row: 4, section: 0)
        case .fiftyFiftyTarget:
            return IndexPath(row: 5, section: 0)
        case .capRiskManagement:
            return IndexPath(row: 6, section: 0)
        case .estimatedSpendPerAcre:
            return IndexPath(row: 7, section: 0)
        case .estimatedSpend:
            return IndexPath(row: 8, section: 0)
        }
    }
    
    var isRebateAttribute: Bool {
        switch self {
        case .allValues, .costShareRebateTotal:
            return false
        case .costShare, .agriClimeCost, .tenNinetyCropsurance, .fiftyFiftyTarget, .capRiskManagement, .estimatedSpendPerAcre, .estimatedSpend:
            return true
        }
    }
    
    var isEnabled: Bool {
        if UserDefaults.standard.object(forKey: "\(self.rawValue)") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: self.rawValue)
    }
    
}
