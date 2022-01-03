//
//  RealmObjectsTestData.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by Matt Jankowiak on 6/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift
import XCTest
@testable import AgriEdgeCalculatorTool

class RealmObjectsTestData {
    
    static var newGrowerA: GrowerObject {
        let grower = GrowerObject()
        grower.growerID = UUID().uuidString
        grower.firstName = "Matt"
        grower.lastName = "Jankowiak"
        grower.farmName = "Matt's Farm"
        grower.email = "matthew.jankowiak@syngenta.com"
        grower.phoneNumber = "630-747-9129"
        grower.zoneID = "Zone A"        
        grower.crops.append(self.newPlantedCropA)
        grower.crops.append(self.newPlantedCropB)
        return grower
    }
    
    static var newGrowerB: GrowerObject {
        let grower = GrowerObject()
        grower.growerID = UUID().uuidString
        grower.firstName = "Lloyd"
        grower.lastName = "Fan"
        grower.farmName = "LLoyd's Farm"
        grower.email = "lloyd.fan@syngenta.com"
        grower.phoneNumber = "555-555-5555"
        grower.zoneID = "Zone B"
        return grower
    }
    
    static var newGrowerC: GrowerObject {
        let grower = GrowerObject()
        grower.growerID = UUID().uuidString
        grower.firstName = "Brett"
        grower.lastName = "Johnsen"
        grower.farmName = "Brett's Farm"
        grower.email = "brett.johnsen@syngenta.com"
        grower.phoneNumber = "847-332-8766"
        grower.zoneID = "Zone C"
        return grower
    }
    
    static var newPlanA: PlanObject {
        let plan = PlanObject()
        plan.planID = UUID().uuidString
        plan.displayName = "New Plan Name"
        return plan
    }
    
    static var newPlanB: PlanObject {
        let plan = PlanObject()
        plan.planID = UUID().uuidString
        plan.displayName = "Another New Plan Name"
        return plan
    }
    
    static var newCropA: CropObject {
        let crop = CropObject()
        crop.cropID = "2e4fbd7e-9921-11e9-b6d2-f40f240f7e8e"
        crop.displayName = "Cucumber"
        crop.zonePrice = List<CropZonePriceObject>()
        return crop
    }
    
    static var newCropB: CropObject {
        let crop = CropObject()
        crop.cropID = "2e4fbbf8-9921-11e9-b6d2-f40f240f7e8e"
        crop.displayName = "Corn"
        let priceObjectA = CropZonePriceObject()
        priceObjectA.price = 30.16
        priceObjectA.zoneKey = "Zone A"
        
        let priceObjectB = CropZonePriceObject()
        priceObjectB.price = 20.80
        priceObjectB.zoneKey = "Zone C"
        
        crop.zonePrice.append(priceObjectA)
        crop.zonePrice.append(priceObjectB)
        
        return crop
    }
    
    static var newPlantedCropA: PlantedCropObject {
        let crop = PlantedCropObject()
        crop.cropID = "2e4fbd7e-9921-11e9-b6d2-f40f240f7e8e"
        crop.plantedAcreage = 1100.0
        return crop
    }
    
    static var newPlantedCropB: PlantedCropObject {
        let crop = PlantedCropObject()
        crop.cropID = "2e4fbbf8-9921-11e9-b6d2-f40f240f7e8e"
        crop.plantedAcreage = 5500.0
        return crop
    }

    static var testGrowers = [RealmObjectsTestData.newGrowerA, RealmObjectsTestData.newGrowerB]
    
}
