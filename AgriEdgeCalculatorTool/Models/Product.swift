//
//  Product.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct Product: Codable, NameSearchable {
    
    var productID = ""
    var displayName = ""
    var measurementUnit = UnitOfMeasure.gallons
    var price = 0.0
    var FFMult = 1.0
    var CapMult = 1.0
    var zonePricing: [String: Double]? = [:]
    var agriClimeRedemptionZonePrice: [String: Double]? = [:]

    init(productObject: ProductObject) {
        self.productID = productObject.productID
        self.displayName = productObject.displayName
        self.measurementUnit = UnitOfMeasure(rawValue: productObject.measurementUnit) ?? .gallons
        self.price = productObject.price
        self.FFMult = productObject.FFMult
        self.CapMult = productObject.capMult
        var zonePricingDict: [String: Double] = [:]
        productObject.zonePricing.forEach { zonePrice in
            zonePricingDict[zonePrice.zoneID] = zonePrice.price
        }
        self.zonePricing = zonePricingDict
        var agriClimeZonePricingDict: [String: Double] = [:]
        productObject.agriClimeRedemptionZonePricing.forEach { agriClimeRedemptionZonePrice in
            agriClimeZonePricingDict[agriClimeRedemptionZonePrice.zoneID] = agriClimeRedemptionZonePrice.redemptionPrice
        }
        self.agriClimeRedemptionZonePrice = agriClimeZonePricingDict
    }
    
    init(displayName: String) {
        self.displayName = displayName
    }
    
}

@objcMembers
class ProductObject: Object {
    
    dynamic var productID = ""
    dynamic var displayName = ""
    dynamic var measurementUnit = ""
    dynamic var price = 0.0
    dynamic var FFMult = 1.0
    dynamic var capMult = 1.0
    dynamic var zonePricing = List<ZonePrice>()
    dynamic var agriClimeRedemptionZonePricing = List<AgriClimeRedemptionZonePrice>()

    override static func primaryKey() -> String? {
        return "productID"
    }
    
    func project(from product: Product) -> Self {
        self.productID = product.productID
        self.displayName = product.displayName
        self.measurementUnit = product.measurementUnit.rawValue
        self.price = product.price
        self.FFMult = product.FFMult
        self.capMult = product.CapMult
        var zonePricingObjects = [ZonePrice]()
        (product.zonePricing ?? [:]).forEach({ (zoneID: String, price: Double) in
            zonePricingObjects.append(ZonePrice.zoneProductPrice(productID: product.productID, zoneID: zoneID, price: price))
        })
        self.zonePricing.append(objectsIn: zonePricingObjects)
        var agriClimeRedemptionZonePricingObjects = [AgriClimeRedemptionZonePrice]()
        (product.agriClimeRedemptionZonePrice ?? [:]).forEach({ (zoneID: String, redemptionPrice: Double) in
            agriClimeRedemptionZonePricingObjects.append(AgriClimeRedemptionZonePrice.agriClimeRedemptionZoneProductPrice(productID: product.productID, zoneID: zoneID, redemptionPrice: redemptionPrice))
        })
        self.agriClimeRedemptionZonePricing.append(objectsIn: agriClimeRedemptionZonePricingObjects)
        return self
    }
    
}

extension String {

    func productNameFromID() -> String? {
        let predicate = NSPredicate(format: "productID = %@", self)
        return PersistenceLayer().fetch(ProductObject.self, predicate: predicate)?.first?.displayName
    }
    
    /// Return the product price for the specified zone. If zone is not found, return default seed price
    func productPriceFromID(zoneID: String) -> Double? {
        let predicate = NSPredicate(format: "productID = %@", self)
        let product = PersistenceLayer().fetch(ProductObject.self, predicate: predicate)?.first
        return product?.zonePricing.filter { $0.zoneID == zoneID }.first?.price ?? product?.price
    }
    
    /// Return the agriClime price for the specified zone. If zone is not found, return nil
    func agriClimeZonePriceFromID(zoneID: String) -> Double? {
        let predicate = NSPredicate(format: "productID = %@", self)
        let product = PersistenceLayer().fetch(ProductObject.self, predicate: predicate)?.first
        return product?.agriClimeRedemptionZonePricing.filter { $0.zoneID == zoneID }.first?.redemptionPrice
    }
    
    func productUoMRatioFromID() -> Double? {
        let predicate = NSPredicate(format: "productID = %@", self)
        guard let UoMName = PersistenceLayer().fetch(ProductObject.self, predicate: predicate)?.first?.measurementUnit else { return 0.0 }
        return UnitOfMeasure(rawValue: UoMName)?.ratio
    }

}
