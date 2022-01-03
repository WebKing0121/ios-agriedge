//
//  ZonePrice.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 11/16/20.
//  Copyright © 2020 Syngenta. All rights reserved.
//

import RealmSwift

@objcMembers
class ZonePrice: Object {
    dynamic var id = ""
    dynamic var zoneID = ""
    dynamic var price = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func zoneProductPrice(productID: String, zoneID: String, price: Double) -> ZonePrice {
        let zoneSeedPrice = ZonePrice()
        zoneSeedPrice.id = productID + zoneID //composite unique key
        zoneSeedPrice.zoneID = zoneID
        zoneSeedPrice.price = price
        return zoneSeedPrice
    }
    
    static func zoneSeedPrice(seedID: String, zoneID: String, price: Double) -> ZonePrice {
        let zoneSeedPrice = ZonePrice()
        zoneSeedPrice.id = seedID + zoneID //composite unique key
        zoneSeedPrice.zoneID = zoneID
        zoneSeedPrice.price = price
        return zoneSeedPrice
    }

}
