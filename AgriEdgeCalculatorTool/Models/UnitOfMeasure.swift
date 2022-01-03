//
//  UnitOfMeasure.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

enum UnitOfMeasure: String, Codable {
    case fluidOunce
    case pints
    case quarts
    case gallons
    case each
    case unit
    case ounces
    case pounds
    case kernel
    case seed
    case bag
    
    init?(rateDisplayName: String) {
        switch rateDisplayName {
        case "fl oz/ac":
            self = .fluidOunce
        case "pints/ac":
            self = .pints
        case "quarts/ac":
            self = .quarts
        case "gallons/ac":
            self = .gallons
        case "each/ac":
            self = .each
        case "unit/ac":
            self = .unit
        case "oz/ac":
            self = .ounces
        case "lbs/ac":
            self = .pounds
        case "kernels/ac":
            self = .kernel
        case "seeds/ac":
            self = .seed
        case "bags/ac":
            self = .bag
        default:
            self = .gallons
        }
    }
    
    init?(totalDisplayName: String) {
        switch totalDisplayName {
        case "fl oz":
            self = .fluidOunce
        case "pints":
            self = .pints
        case "quarts":
            self = .quarts
        case "gallons":
            self = .gallons
        case "each":
            self = .each
        case "unit":
            self = .unit
        case "oz":
            self = .ounces
        case "lbs":
            self = .pounds
        default:
            self = .gallons
        }
    }
}

extension UnitOfMeasure {
    
    var rateDisplayName: String {
        switch self {
        case .fluidOunce:
            return "fl oz/ac"
        case .pints:
            return "pints/ac"
        case .quarts:
            return "quarts/ac"
        case .gallons:
            return "gallons/ac"
        case .each:
            return "each/ac"
        case .unit:
            return "unit/ac"
        case .ounces:
            return "oz/ac"
        case .pounds:
            return "lbs/ac"
        case .kernel:
            return "kernels/ac"
        case .seed:
            return "seeds/ac"
        case .bag:
            return "bags/ac"
        }
    }
    
    var totalDisplayName: String {
        switch self {
        case .fluidOunce:
            return "fl oz"
        case .pints:
            return "pints"
        case .quarts:
            return "quarts"
        case .gallons:
            return "gallons"
        case .each:
            return "each"
        case .unit:
            return "unit"
        case .ounces:
            return "oz"
        case .pounds:
            return "lbs"
        case .kernel:
            return "kernels"
        case .seed:
            return "seeds"
        case .bag:
            return "bags"
        }
    }
    
    var topLevelTotalDisplayName: String {
        switch self {
        case .fluidOunce, .pints, .quarts, .gallons:
            return "gallons"
        case .each:
            return "each"
        case .unit:
            return "unit"
        case .ounces, .pounds:
            return "lbs"
        case .kernel:
            return "kernels"
        case .seed:
            return "seeds"
        case .bag:
            return "bags"
        }
    }
    
    var ratio: Double {
        switch self {
        case .fluidOunce:
            return 128
        case .pints:
            return 8
        case .quarts:
            return 4
        case .gallons:
            return 1
        case .each:
            return 1
        case .unit:
            return 1
        case .ounces:
            return 16
        case .pounds:
            return 1
        case .seed, .kernel, .bag:
            return 1
        }
    }
    
    var rateUnitOptions: [String] {
        switch self {
        case .gallons, .quarts, .pints, .fluidOunce:
            return [UnitOfMeasure.fluidOunce.rateDisplayName,
                    UnitOfMeasure.pints.rateDisplayName,
                    UnitOfMeasure.quarts.rateDisplayName,
                    UnitOfMeasure.gallons.rateDisplayName]
        case .pounds, .ounces:
            return [UnitOfMeasure.ounces.rateDisplayName,
                    UnitOfMeasure.pounds.rateDisplayName]
        case .each:
            return [UnitOfMeasure.each.rateDisplayName]
        case .unit:
            return [UnitOfMeasure.unit.rateDisplayName]
        case .kernel:
            return [UnitOfMeasure.kernel.rateDisplayName, UnitOfMeasure.bag.rateDisplayName]
        case .seed:
            return [UnitOfMeasure.seed.rateDisplayName, UnitOfMeasure.bag.rateDisplayName]
        case .bag:
            return [UnitOfMeasure.bag.rateDisplayName]
        }
    }
    
    var totalUnitOptions: [String] {
        switch self {
        case .gallons, .quarts, .pints, .fluidOunce:
            return [UnitOfMeasure.fluidOunce.totalDisplayName,
                    UnitOfMeasure.pints.totalDisplayName,
                    UnitOfMeasure.quarts.totalDisplayName,
                    UnitOfMeasure.gallons.totalDisplayName]
        case .pounds, .ounces:
            return [UnitOfMeasure.ounces.totalDisplayName,
                    UnitOfMeasure.pounds.totalDisplayName]
        case .each:
            return [UnitOfMeasure.each.totalDisplayName]
        case .unit:
            return [UnitOfMeasure.unit.totalDisplayName]
        case .kernel, .seed, .bag:
            return [UnitOfMeasure.bag.totalDisplayName]
        }
    }
}
