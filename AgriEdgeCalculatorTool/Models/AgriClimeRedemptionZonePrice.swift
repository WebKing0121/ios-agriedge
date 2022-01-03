//
//  ZonePrice.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 11/16/20.
//  Copyright © 2020 Syngenta. All rights reserved.
//

import RealmSwift

@objcMembers
class AgriClimeRedemptionZonePrice: Object {
    dynamic var id = ""
    dynamic var zoneID = ""
    dynamic var redemptionPrice = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func agriClimeRedemptionZoneProductPrice(productID: String, zoneID: String, redemptionPrice: Double) -> AgriClimeRedemptionZonePrice {
        let agriClimeRedemptionZonePrice = AgriClimeRedemptionZonePrice()
        agriClimeRedemptionZonePrice.id = productID + zoneID //composite unique key
        agriClimeRedemptionZonePrice.zoneID = zoneID
        agriClimeRedemptionZonePrice.redemptionPrice = redemptionPrice
        return agriClimeRedemptionZonePrice
    }

}
