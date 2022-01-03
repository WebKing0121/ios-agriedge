//
//  PlanConfidence.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 6/10/20.
//  Copyright © 2020 Syngenta. All rights reserved.
//

import UIKit

enum PlanConfidence: Int, CaseIterable, Codable {
    case noSelection = 0, level1, level2, level3, level4, level5
    static public let `default`: PlanConfidence = .noSelection

    var title: String {
        switch self {
        case .noSelection: return "No Selection"
        case .level1: return "90% - 100%"
        case .level2: return "75% - 90%"
        case .level3: return "50% - 75%"
        case .level4: return "10% - 50%"
        case .level5: return "0% - 10%"
        }
    }
    
    var color: UIColor {
        switch self {
        case .noSelection: return UIColor(red: 204 / 255, green: 208 / 255, blue: 215 / 255, alpha: 1)
        case .level1: return UIColor(red: 83 / 255, green: 205 / 255, blue: 104 / 255, alpha: 1)
        case .level2: return UIColor(red: 255 / 255, green: 211 / 255, blue: 61 / 255, alpha: 1)
        case .level3: return UIColor(red: 255 / 255, green: 146 / 255, blue: 46 / 255, alpha: 1)
        case .level4: return UIColor(red: 252 / 255, green: 82 / 255, blue: 83 / 255, alpha: 1)
        case .level5: return UIColor(red: 52 / 255, green: 153 / 255, blue: 241 / 255, alpha: 1)
        }
    }
}
