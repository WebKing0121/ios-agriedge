//
//  Application.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct Application: Codable {
    var applicationID = ""
    var productID = ""
    var cropID = ""
    var appliedAcreage = ""
    var appliedRate = ""
    var appliedUoM = UnitOfMeasure.ounces
    var enrollInAgriClime = 0
    var agriClimeQuantity: String?
    
    init(applicationObject: ApplicationObject) {
        self.applicationID = applicationObject.applicationID
        self.productID = applicationObject.productID
        self.cropID = applicationObject.cropID
        self.appliedAcreage = applicationObject.appliedAcreage
        self.appliedRate = applicationObject.appliedRate
        self.appliedUoM = UnitOfMeasure(rawValue: applicationObject.appliedUoM) ?? UnitOfMeasure.ounces
        self.enrollInAgriClime = applicationObject.enrollInAgriClime
        self.agriClimeQuantity = applicationObject.agriClimeQuantity
    }
    
    init(applicationID: String, productID: String, cropID: String, appliedAcreage: String, appliedRate: String, appliedUoM: UnitOfMeasure, enrollInAgriClime: Int, agriClimeQuantity: String) {
        self.applicationID = applicationID
        self.productID = productID
        self.cropID = cropID
        self.appliedAcreage = appliedAcreage
        self.appliedRate = appliedRate
        self.appliedUoM = appliedUoM
        self.enrollInAgriClime = enrollInAgriClime
        self.agriClimeQuantity = agriClimeQuantity
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
class ApplicationObject: Object {
    dynamic var applicationID = ""
    dynamic var productID = ""
    dynamic var cropID = ""
    dynamic var appliedAcreage = ""
    dynamic var appliedRate = ""
    dynamic var appliedUoM = UnitOfMeasure.ounces.rawValue
    dynamic var enrollInAgriClime = 0
    dynamic var agriClimeQuantity: String?
    
    func project(from application: Application) -> Self {
        self.applicationID = application.applicationID
        self.productID = application.productID
        self.cropID = application.cropID
        self.appliedAcreage = application.appliedAcreage
        self.appliedRate = application.appliedRate
        self.appliedUoM = application.appliedUoM.rawValue
        self.enrollInAgriClime = application.enrollInAgriClime
        self.agriClimeQuantity = application.agriClimeQuantity
        return self
    }
    
    override static func primaryKey() -> String? {
        return "applicationID"
    }
}
