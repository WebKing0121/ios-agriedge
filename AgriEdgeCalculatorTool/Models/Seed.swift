//
//  Seed.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 9/22/20.
//  Copyright © 2020 Syngenta. All rights reserved.
//

import RealmSwift

struct Seed: Codable, NameSearchable {
    
    var seedID = ""
    var displayName = ""
    var price = 0.0
    var stdUnit = UnitOfMeasure.seed
    var stdFactor = 1.0
    var stdPackageUnit = UnitOfMeasure.bag
    var zonePricing: [String: Double]? = [:]
    
    enum CodingKeys: String, CodingKey {
        case seedID = "productID"
        case displayName
        case price
        case stdUnit
        case stdFactor
        case stdPackageUnit = "measurementUnit"
        case zonePricing
    }
    
    init(seedObject: SeedObject) {
        self.seedID = seedObject.seedID
        self.displayName = seedObject.displayName
        self.price = seedObject.price
        self.stdUnit = UnitOfMeasure(rawValue: seedObject.stdUnit) ?? .seed
        self.stdFactor = seedObject.stdFactor
        self.stdPackageUnit = UnitOfMeasure(rawValue: seedObject.stdPackageUnit) ?? .bag
        var zonePricingDict: [String: Double] = [:]
        seedObject.zonePricing.forEach { zonePrice in
            zonePricingDict[zonePrice.zoneID] = zonePrice.price
        }
        self.zonePricing = zonePricingDict
    }
    
    init(displayName: String) {
        self.displayName = displayName
    }
    
}

@objcMembers
class SeedObject: Object {
    
    dynamic var seedID = ""
    dynamic var displayName = ""
    dynamic var price = 0.0
    dynamic var stdUnit = ""
    dynamic var stdFactor = 1.0
    dynamic var stdPackageUnit = ""
    dynamic var zonePricing = List<ZonePrice>()

    override static func primaryKey() -> String? {
        return "seedID"
    }
    
    func project(from seed: Seed) -> Self {
        self.seedID = seed.seedID
        self.displayName = seed.displayName
        self.price = seed.price
        self.stdUnit = seed.stdUnit.rawValue
        self.stdFactor = seed.stdFactor
        self.stdPackageUnit = seed.stdPackageUnit.rawValue
        var zonePricingObjects = [ZonePrice]()
        (seed.zonePricing ?? [:]).forEach({ (zoneID: String, price: Double) in
            zonePricingObjects.append(ZonePrice.zoneSeedPrice(seedID: seed.seedID, zoneID: zoneID, price: price))
        })
        self.zonePricing.append(objectsIn: zonePricingObjects)
        return self
    }
    
}

extension String {

    func seedNameFromID() -> String? {
        let predicate = NSPredicate(format: "seedID = %@", self)
        return PersistenceLayer().fetch(SeedObject.self, predicate: predicate)?.first?.displayName
    }
    
    /// Return the seed price for the specified zone. If zone is not found, return default seed price
    func seedPriceFromID(zoneID: String) -> Double? {
        let predicate = NSPredicate(format: "seedID = %@", self)
        let seed = PersistenceLayer().fetch(SeedObject.self, predicate: predicate)?.first
        return seed?.zonePricing.filter { $0.zoneID == zoneID }.first?.price ?? seed?.price
    }
    
    func seedStdFactorFromID() -> Double {
        let predicate = NSPredicate(format: "seedID = %@", self)
        return PersistenceLayer().fetch(SeedObject.self, predicate: predicate)?.first?.stdFactor ?? 1.0
    }

}
