//
//  ProductTrigger.swift
//  AgriEdgeCalculatorTool
//
//  Created by lloyd on 7/15/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct ProductTrigger: Codable {
    var productTriggerID = 0
    var cropID = ""
    var type = ProductTriggerType.Threshold
    var triggerPrice = 0.0
    var areaMult: Double?
    var ffMult = 1.0
    var capMult = 1.0
    var limitAcres = false
    var limitParentAcres = false
    var minimumRateUsed: Double?
    var zoneID = ""
    var productsID: [String]
    var parentsID: [String]?
    
    init(productTriggerObject: ProductTriggerObject) {
        self.productTriggerID = productTriggerObject.productTriggerID
        self.cropID = productTriggerObject.cropID
        self.type = ProductTriggerType(rawValue: productTriggerObject.type) ?? ProductTriggerType.Threshold
        self.zoneID = productTriggerObject.zoneID
        self.triggerPrice = productTriggerObject.triggerPrice
        self.areaMult = productTriggerObject.areaMult.value
        self.ffMult = productTriggerObject.ffMult
        self.capMult = productTriggerObject.capMult
        self.limitAcres = productTriggerObject.limitAcres
        self.limitParentAcres = productTriggerObject.limitParentAcres
        self.minimumRateUsed = productTriggerObject.minimumRateUsed.value
        self.productsID = Array(productTriggerObject.productsID)
        if !productTriggerObject.parentProductsID.isEmpty {
            self.parentsID = Array(productTriggerObject.parentProductsID)
        }
    }
    
}

@objcMembers
class ProductTriggerObject: Object {
    dynamic var productTriggerID = 0
    dynamic var cropID = ""
    dynamic var type = ProductTriggerType.Threshold.rawValue
    dynamic var zoneID = ""
    dynamic var triggerPrice = 0.0
    dynamic var areaMult = RealmOptional<Double>()
    dynamic var ffMult = 1.0
    dynamic var capMult = 1.0
    dynamic var limitAcres = false
    dynamic var limitParentAcres = false
    dynamic var minimumRateUsed = RealmOptional<Double>()
    dynamic var productsID = List<String>()
    dynamic var parentProductsID = List<String>()
    
    func project(from productTrigger: ProductTrigger) -> Self {
        self.productTriggerID = productTrigger.productTriggerID
        self.cropID = productTrigger.cropID
        self.type = productTrigger.type.rawValue
        self.zoneID = productTrigger.zoneID
        self.triggerPrice = productTrigger.triggerPrice
        self.areaMult = RealmOptional<Double>(productTrigger.areaMult)
        self.ffMult = productTrigger.ffMult
        self.capMult = productTrigger.capMult
        self.limitAcres = productTrigger.limitAcres
        self.limitParentAcres = productTrigger.limitParentAcres
        self.minimumRateUsed = RealmOptional<Double>(productTrigger.minimumRateUsed)
        productTrigger.productsID.forEach({ zoneUUID in
            self.productsID.append(zoneUUID)
        })
        productTrigger.parentsID?.forEach({ zoneUUID in
            self.parentProductsID.append(zoneUUID)
        })
        return self
    }
    
    override static func primaryKey() -> String? {
        return "productTriggerID"
    }
    
}

enum ProductTriggerType: String, Codable {
    case Redemption
    case Threshold
}
