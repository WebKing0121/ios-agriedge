//
//  SeedApplication.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 9/20/20.
//  Copyright © 2020 Syngenta. All rights reserved.
//

import RealmSwift

struct SeedApplication: Codable {
    var seedApplicationID = ""
    var seedID = ""
    var cropID = ""
    var appliedAcreage = ""
    var appliedRate = ""
    var appliedUoM = UnitOfMeasure.unit
    
    init(seedApplicationObject: SeedApplicationObject) {
        self.seedApplicationID = seedApplicationObject.seedApplicationID
        self.seedID = seedApplicationObject.seedID
        self.cropID = seedApplicationObject.cropID
        self.appliedAcreage = seedApplicationObject.appliedAcreage
        self.appliedRate = seedApplicationObject.appliedRate
        self.appliedUoM = UnitOfMeasure(rawValue: seedApplicationObject.appliedUoM) ?? UnitOfMeasure.unit
    }
    
    init(seedApplicationID: String, seedID: String, cropID: String, appliedAcreage: String, appliedRate: String, appliedUoM: UnitOfMeasure) {
        self.seedApplicationID = seedApplicationID
        self.seedID = seedID
        self.cropID = cropID
        self.appliedAcreage = appliedAcreage
        self.appliedRate = appliedRate
        self.appliedUoM = appliedUoM
    }
    // TODO: Remove this code once we no longer need it...this is an example of how to update the model objects to handle null values coming back from the server. We may need to update these so they fail better in these cases. Currently just a blanket error is thrown to the user, this may be what we want to stick with.
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//            applicationID = try container.decode(String.self, forKey: .applicationID)
//            cropID = try container.decode(String.self, forKey: .cropID)
//            appliedAcreage = try container.decode(String.self, forKey: .appliedAcreage)
//            appliedRate = try container.decode(String.self, forKey: .appliedRate)
//            appliedUoM = try container.decode(UnitOfMeasure.self, forKey: .appliedUoM)
//            productID = (try container.decodeIfPresent(String.self, forKey: .productID)) ?? "Missing Product ID"
//    }
}

@objcMembers
class SeedApplicationObject: Object {
    dynamic var seedApplicationID = ""
    dynamic var seedID = ""
    dynamic var cropID = ""
    dynamic var appliedAcreage = ""
    dynamic var appliedRate = ""
    dynamic var appliedUoM = UnitOfMeasure.seed.rawValue
    
    func project(from seedApplication: SeedApplication) -> Self {
        self.seedApplicationID = seedApplication.seedApplicationID
        self.seedID = seedApplication.seedID
        self.cropID = seedApplication.cropID
        self.appliedAcreage = seedApplication.appliedAcreage
        self.appliedRate = seedApplication.appliedRate
        self.appliedUoM = seedApplication.appliedUoM.rawValue
        return self
    }
    
    override static func primaryKey() -> String? {
        return "seedApplicationID"
    }
}
