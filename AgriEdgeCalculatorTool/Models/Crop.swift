//
//  Crop.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct Crop: Codable, NameSearchable {
    var cropID = ""
    var displayName = ""
    var zonePrice: [String: Double]
    var FFMult: [String: Double]
    var CapMult: [String: Double]
    var seedZonePrice: [String: Double]?
    var seedFFMult: [String: Double]?
    var seedCapMult: [String: Double]?
    
    init(cropObject: CropObject) {
        self.cropID = cropObject.cropID
        self.displayName = cropObject.displayName
        self.zonePrice = Dictionary(uniqueKeysWithValues: Array(cropObject.zonePrice).map { ($0.zoneKey, $0.price) })
        self.FFMult = Dictionary(uniqueKeysWithValues: Array(cropObject.zonePrice).map { ($0.zoneKey, $0.FFMult) })
        self.CapMult = Dictionary(uniqueKeysWithValues: Array(cropObject.zonePrice).map { ($0.zoneKey, $0.capMult) })
        self.seedZonePrice = Dictionary(uniqueKeysWithValues: Array(cropObject.seedZonePrice).map { ($0.zoneKey, $0.price) })
        self.seedFFMult = Dictionary(uniqueKeysWithValues: Array(cropObject.seedZonePrice).map { ($0.zoneKey, $0.FFMult) })
        self.seedCapMult = Dictionary(uniqueKeysWithValues: Array(cropObject.seedZonePrice).map { ($0.zoneKey, $0.capMult) })
    }
}

@objcMembers
class CropObject: Object {
    dynamic var cropID = ""
    dynamic var displayName = ""
    dynamic var zonePrice = List<CropZonePriceObject>()
    dynamic var seedZonePrice = List<CropZonePriceObject>()

    override static func primaryKey() -> String? {
        return "cropID"
    }
    
    func project(from crop: Crop) -> Self {
        self.cropID = crop.cropID
        self.displayName = crop.displayName
        var cropZonePriceObjects = [CropZonePriceObject]()
        crop.zonePrice.forEach({ (zoneID: String, price: Double) in
            let newObject = CropZonePriceObject.zonePrice(cropID: crop.cropID,
                                                          zoneID: zoneID,
                                                          price: price,
                                                          ffMult: crop.FFMult[zoneID] ?? 1.0,
                                                          capMult: crop.CapMult[zoneID] ?? 1.0)
            cropZonePriceObjects.append(newObject)
        })
        self.zonePrice.append(objectsIn: cropZonePriceObjects)
        var cropZoneSeedPriceObjects = [CropZonePriceObject]()
        (crop.seedZonePrice ?? [:]).forEach({ (zoneID: String, price: Double) in
            let newObject = CropZonePriceObject.seedZonePrice(cropID: crop.cropID,
                                                              zoneID: zoneID,
                                                              price: price,
                                                              ffMult: crop.seedFFMult?[zoneID] ?? 1.0,
                                                              capMult: crop.seedCapMult?[zoneID] ?? 1.0)
            cropZoneSeedPriceObjects.append(newObject)
        })
        self.seedZonePrice.append(objectsIn: cropZoneSeedPriceObjects)
        return self
    }
    
}

@objcMembers
class CropZonePriceObject: Object {
    dynamic var id = ""
    dynamic var zoneKey = ""
    dynamic var price = 0.0
    dynamic var FFMult = 1.0
    dynamic var capMult = 1.0

    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func zonePrice(cropID: String, zoneID: String, price: Double, ffMult: Double, capMult: Double) -> CropZonePriceObject {
        let newObject = CropZonePriceObject()
        newObject.id = "zonePrice" + cropID + zoneID //composite key so that db can enforce uniqueness
        newObject.zoneKey = zoneID
        newObject.price = price
        newObject.FFMult = ffMult
        newObject.capMult = capMult
        return newObject
    }
    
    static func seedZonePrice(cropID: String, zoneID: String, price: Double, ffMult: Double, capMult: Double) -> CropZonePriceObject {
        let newObject = CropZonePriceObject()
        newObject.id = "seedZonePrice" + cropID + zoneID //composite key so that db can enforce uniqueness
        newObject.zoneKey = zoneID
        newObject.price = price
        newObject.FFMult = ffMult
        newObject.capMult = capMult
        return newObject
    }

}

extension String {
    
    func cropNameFromID() -> String? {
        let predicate = NSPredicate(format: "cropID = %@", self)
        return PersistenceLayer().fetch(CropObject.self, predicate: predicate)?.first?.displayName
    }
    
}
