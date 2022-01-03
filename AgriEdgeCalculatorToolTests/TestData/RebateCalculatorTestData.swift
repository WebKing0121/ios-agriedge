//
//  RebateCalculatorTestData.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by lloyd on 7/17/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift
import XCTest
@testable import AgriEdgeCalculatorTool

class RebateCalculatorTestData {
    
    // MARK: Test Product Variables
    
    static var trivaPro: ProductObject {
        var trivaPro = Product(displayName: "TrivaPro")
        trivaPro.productID = "1"
        trivaPro.measurementUnit = UnitOfMeasure.gallons
        trivaPro.price = 26.67
        trivaPro.FFMult = 1.6
        trivaPro.CapMult = 1.2
        return ProductObject().project(from: trivaPro)
    }
    
    static var ridomilGoldSL: ProductObject {
        var ridomilGoldSL = Product(displayName: "Ridomil Gold SL")
        ridomilGoldSL.productID = "2"
        ridomilGoldSL.measurementUnit = UnitOfMeasure.gallons
        ridomilGoldSL.price = 95
        ridomilGoldSL.FFMult = 1.6
        ridomilGoldSL.CapMult = 1.2
        return ProductObject().project(from: ridomilGoldSL)
    }
    
    static var ridomilGoldCopper: ProductObject {
        var ridomilGoldCopper = Product(displayName: "Ridomil Gold Copper")
        ridomilGoldCopper.productID = "3"
        ridomilGoldCopper.measurementUnit = UnitOfMeasure.gallons
        ridomilGoldCopper.price = 79.17
        ridomilGoldCopper.FFMult = 1.6
        ridomilGoldCopper.CapMult = 1.2
        return ProductObject().project(from: ridomilGoldCopper)
    }
    
    static var taviumWVaporGrip: ProductObject {
        var taviumWVaporGrip = Product(displayName: "Tavium W/ VaporGrip")
        taviumWVaporGrip.productID = "4"
        taviumWVaporGrip.measurementUnit = UnitOfMeasure.gallons
        taviumWVaporGrip.price = 80
        taviumWVaporGrip.FFMult = 1.6
        taviumWVaporGrip.CapMult = 1.2
        return ProductObject().project(from: taviumWVaporGrip)
    }
    
    static var besiege: ProductObject {
        var besiege = Product(displayName: "Besiege")
        besiege.productID = "5"
        besiege.measurementUnit = UnitOfMeasure.gallons
        besiege.price = 1342.27
        besiege.FFMult = 1.6
        besiege.CapMult = 1.2
        return ProductObject().project(from: besiege)
    }
    
    static var sequence: ProductObject {
        var sequence = Product(displayName: "Sequence")
        sequence.productID = "6"
        sequence.measurementUnit = UnitOfMeasure.gallons
        sequence.price = 40.29
        sequence.FFMult = 1.6
        sequence.CapMult = 1.2
        return ProductObject().project(from: sequence)
    }

    static var cruiserMaxxPotatoExtreme: ProductObject {
        var cruiserMaxxPotatoExtreme = Product(displayName: "CruiserMaxx Potato Extreme")
        cruiserMaxxPotatoExtreme.productID = "7"
        cruiserMaxxPotatoExtreme.measurementUnit = UnitOfMeasure.gallons
        cruiserMaxxPotatoExtreme.price = 561
        cruiserMaxxPotatoExtreme.FFMult = 1.6
        cruiserMaxxPotatoExtreme.CapMult = 1.2
        return ProductObject().project(from: cruiserMaxxPotatoExtreme)
    }
    
    static var revusTop: ProductObject {
        var revusTop = Product(displayName: "Revus Top")
        revusTop.productID = "8"
        revusTop.measurementUnit = UnitOfMeasure.gallons
        revusTop.price = 320.63
        revusTop.FFMult = 1.6
        revusTop.CapMult = 1.2
        return ProductObject().project(from: revusTop)
    }
    
    static var clarivaEliteBeans: ProductObject {
        var clarivaEliteBeans = Product(displayName: "Clariva Elite Beans")
        clarivaEliteBeans.productID = "9"
        clarivaEliteBeans.measurementUnit = UnitOfMeasure.gallons
        clarivaEliteBeans.price = 97
        clarivaEliteBeans.FFMult = 1.6
        clarivaEliteBeans.CapMult = 1.2
        return ProductObject().project(from: clarivaEliteBeans)
    }
    
    static var avictaCompleteBeans: ProductObject {
        var avictaCompleteBeans = Product(displayName: "Avicta Complete Beans")
        avictaCompleteBeans.productID = "10"
        avictaCompleteBeans.measurementUnit = UnitOfMeasure.gallons
        avictaCompleteBeans.price = 69.29
        avictaCompleteBeans.FFMult = 1.6
        avictaCompleteBeans.CapMult = 1.2
        return ProductObject().project(from: avictaCompleteBeans)
    }
    
    // MARK: Test Crop Variables
    
    static var soybeans: CropObject {
        let soybean = CropObject()
        soybean.cropID = "1"
        soybean.displayName = "Soybeans"
        soybean.zonePrice = List<CropZonePriceObject>()
        let RMFivePriceObject = CropZonePriceObject()
        RMFivePriceObject.zoneKey = "RM 5"
        RMFivePriceObject.price = 9
        RMFivePriceObject.FFMult = 1.6
        RMFivePriceObject.capMult = 1.2
        soybean.zonePrice.append(RMFivePriceObject)
        let SECCPriceObject = CropZonePriceObject()
        SECCPriceObject.zoneKey = "SEC C"
        SECCPriceObject.price = 23
        SECCPriceObject.FFMult = 1.6
        SECCPriceObject.capMult = 1.2
        soybean.zonePrice.append(SECCPriceObject)
        let WHFiveOnePriceObject = CropZonePriceObject()
        WHFiveOnePriceObject.zoneKey = "WH 51"
        WHFiveOnePriceObject.price = 25
        WHFiveOnePriceObject.FFMult = 1.6
        WHFiveOnePriceObject.capMult = 1.2
        soybean.zonePrice.append(WHFiveOnePriceObject)
        return soybean
    }
    
    static var potato: CropObject {
        let potato = CropObject()
        potato.cropID = "2"
        potato.displayName = "Potato"
        potato.zonePrice = List<CropZonePriceObject>()
        let PNWSixPriceObject = CropZonePriceObject()
        PNWSixPriceObject.zoneKey = "PNW 6"
        PNWSixPriceObject.price = 35
        PNWSixPriceObject.FFMult = 1.6
        PNWSixPriceObject.capMult = 1.2
        potato.zonePrice.append(PNWSixPriceObject)
        let WHZeroOnePriceObject = CropZonePriceObject()
        WHZeroOnePriceObject.zoneKey = "WH 01"
        WHZeroOnePriceObject.price = 74
        WHZeroOnePriceObject.FFMult = 1.6
        WHZeroOnePriceObject.capMult = 1.2
        potato.zonePrice.append(WHZeroOnePriceObject)
        return potato
    }
    
    static var cotton: CropObject {
        let cotton = CropObject()
        cotton.cropID = "3"
        cotton.displayName = "Cotton"
        cotton.zonePrice = List<CropZonePriceObject>()
        let SECCPriceObject = CropZonePriceObject()
        SECCPriceObject.zoneKey = "SEC C"
        SECCPriceObject.price = 18.53
        SECCPriceObject.FFMult = 1.6
        SECCPriceObject.capMult = 1.2
        cotton.zonePrice.append(SECCPriceObject)
        return cotton
    }
    
    static var sugarBeets: CropObject {
        let sugarBeets = CropObject()
        sugarBeets.cropID = "4"
        sugarBeets.displayName = "Sugar Beets"
        sugarBeets.zonePrice = List<CropZonePriceObject>()
        let WHZeroOnePriceObject = CropZonePriceObject()
        WHZeroOnePriceObject.zoneKey = "WH 01"
        WHZeroOnePriceObject.price = 15.62
        WHZeroOnePriceObject.FFMult = 1.6
        WHZeroOnePriceObject.capMult = 1.2
        sugarBeets.zonePrice.append(WHZeroOnePriceObject)
        return sugarBeets
    }
    
    // MARK: Grower Helper Variables
    
    static var GrowerOnePlantedCrop: PlantedCrop {
        var plantedCrop = PlantedCrop(crop: Crop(cropObject: soybeans))
        plantedCrop.plantedAcreage = 1000
        return plantedCrop
    }
    
    static var GrowerTwoPlantedCrop: PlantedCrop {
        var plantedCrop = PlantedCrop(crop: Crop(cropObject: potato))
        plantedCrop.plantedAcreage = 1000
        return plantedCrop
    }
    
    static var GrowerThreePlantedCrop: PlantedCrop {
        var plantedCrop = PlantedCrop(crop: Crop(cropObject: cotton))
        plantedCrop.plantedAcreage = 1000
        return plantedCrop
    }
    
    static var GrowerFourPlantedCrop: PlantedCrop {
        var plantedCrop = PlantedCrop(crop: Crop(cropObject: soybeans))
        plantedCrop.plantedAcreage = 2000
        return plantedCrop
    }
    
    static var GrowerFivePlantedCrop: PlantedCrop {
        var plantedCrop = PlantedCrop(crop: Crop(cropObject: sugarBeets))
        plantedCrop.plantedAcreage = 2000
        return plantedCrop
    }
    
    static var GrowerSixPlantedCrop: PlantedCrop {
        var plantedCrop = PlantedCrop(crop: Crop(cropObject: potato))
        plantedCrop.plantedAcreage = 2000
        return plantedCrop
    }
    
    static var GrowerSevenPlantedCrop: PlantedCrop {
        var plantedCrop = PlantedCrop(crop: Crop(cropObject: soybeans))
        plantedCrop.plantedAcreage = 2000
        return plantedCrop
    }

    // MARK: Plan Data Variables
    
    static var applicationforPlanOne: Application {
        let application = Application(applicationID: "1", productID: "1", cropID: "1", appliedAcreage: "750", appliedRate: "1", appliedUoM: UnitOfMeasure.gallons)
        return application
    }

    static var applicationOneforPlanTwo: Application {
        let application = Application(applicationID: "2", productID: "2", cropID: "2", appliedAcreage: "500", appliedRate: "1", appliedUoM: UnitOfMeasure.gallons)
        return application
    }
    
    static var applicationTwoforPlanTwo: Application {
        let application = Application(applicationID: "3", productID: "3", cropID: "2", appliedAcreage: "600", appliedRate: "1", appliedUoM: UnitOfMeasure.gallons)
        return application
    }
    
    static var applicationforPlanThree: Application {
        let application = Application(applicationID: "4", productID: "4", cropID: "3", appliedAcreage: "750", appliedRate: "1", appliedUoM: UnitOfMeasure.gallons)
        return application
    }
    
    static var applicationOneforPlanFour: Application {
        let application = Application(applicationID: "5", productID: "5", cropID: "1", appliedAcreage: "750", appliedRate: "10", appliedUoM: UnitOfMeasure.fluidOunce)
        return application
    }
    
    static var applicationTwoforPlanFour: Application {
        let application = Application(applicationID: "6", productID: "5", cropID: "1", appliedAcreage: "250", appliedRate: "7", appliedUoM: UnitOfMeasure.fluidOunce)
        return application
    }
    
    static var applicationforPlanFive: Application {
        let application = Application(applicationID: "7", productID: "6", cropID: "4", appliedAcreage: "1500", appliedRate: "2", appliedUoM: UnitOfMeasure.quarts)
        return application
    }
    
    static var applicationOneforPlanSix: Application {
        let application = Application(applicationID: "8", productID: "7", cropID: "2", appliedAcreage: "1500", appliedRate: "0.5", appliedUoM: UnitOfMeasure.fluidOunce)
        return application
    }
    
    static var applicationTwoforPlanSix: Application {
        let application = Application(applicationID: "9", productID: "8", cropID: "2", appliedAcreage: "2000", appliedRate: "8", appliedUoM: UnitOfMeasure.fluidOunce)
        return application
    }
    
    static var applicationOneforPlanSeven: Application {
        let application = Application(applicationID: "10", productID: "9", cropID: "1", appliedAcreage: "500", appliedRate: "1", appliedUoM: UnitOfMeasure.gallons)
        return application
    }
    
    static var applicationTwoforPlanSeven: Application {
        let application = Application(applicationID: "11", productID: "10", cropID: "1", appliedAcreage: "700", appliedRate: "1", appliedUoM: UnitOfMeasure.gallons)
        return application
    }
    
    static var planOne: Plan {
        var plan = Plan()
        plan.applications = [applicationforPlanOne]
        plan.cropYear = "2020"
        plan.displayName = "test 1"
        plan.growerID = "1"
        plan.planID = "1"
        return plan
    }
    
    static var planTwo: Plan {
        var plan = Plan()
        plan.applications = [applicationOneforPlanTwo, applicationTwoforPlanTwo]
        plan.cropYear = "2020"
        plan.displayName = "test 2"
        plan.growerID = "2"
        plan.planID = "2"
        return plan
    }
    
    static var planThree: Plan {
        var plan = Plan()
        plan.applications = [applicationforPlanThree]
        plan.cropYear = "2020"
        plan.displayName = "test 3"
        plan.growerID = "3"
        plan.planID = "3"
        return plan
    }
    
    static var planFour: Plan {
        var plan = Plan()
        plan.applications = [applicationOneforPlanFour, applicationTwoforPlanFour]
        plan.cropYear = "2020"
        plan.displayName = "test 4"
        plan.growerID = "4"
        plan.planID = "4"
        return plan
    }
    
    static var planFive: Plan {
        var plan = Plan()
        plan.applications = [applicationforPlanFive]
        plan.cropYear = "2020"
        plan.displayName = "test 5"
        plan.growerID = "5"
        plan.planID = "5"
        return plan
    }
    
    static var planSix: Plan {
        var plan = Plan()
        plan.applications = [applicationOneforPlanSix, applicationTwoforPlanSix]
        plan.cropYear = "2020"
        plan.displayName = "test 6"
        plan.growerID = "6"
        plan.planID = "6"
        return plan
    }
    
    static var planSeven: Plan {
        var plan = Plan()
        plan.applications = [applicationOneforPlanSeven, applicationTwoforPlanSeven]
        plan.cropYear = "2020"
        plan.displayName = "test 7"
        plan.growerID = "7"
        plan.planID = "7"
        return plan
    }
    
    // MARK: Grower Variables
    
    static var growerOne: GrowerObject {
        var grower = Grower()
        grower.crops = [GrowerOnePlantedCrop]
        grower.growerID = "1"
        grower.zoneID = "RM 5"
        grower.firstName = "test"
        grower.lastName = "1"
        grower.plans = [planOne]
        return GrowerObject().project(from: grower)
    }
    
    static var growerTwo: GrowerObject {
        var grower = Grower()
        grower.crops = [GrowerTwoPlantedCrop]
        grower.growerID = "2"
        grower.zoneID = "PNW 6"
        grower.firstName = "test"
        grower.lastName = "2"
        grower.plans = [planTwo]
        return GrowerObject().project(from: grower)
    }
    
    static var growerThree: GrowerObject {
        var grower = Grower()
        grower.crops = [GrowerThreePlantedCrop]
        grower.growerID = "3"
        grower.zoneID = "SEC C"
        grower.firstName = "test"
        grower.lastName = "3"
        grower.plans = [planThree]
        return GrowerObject().project(from: grower)
    }
    
    static var growerFour: GrowerObject {
        var grower = Grower()
        grower.crops = [GrowerFourPlantedCrop]
        grower.growerID = "4"
        grower.zoneID = "SEC C"
        grower.firstName = "test"
        grower.lastName = "4"
        grower.plans = [planFour]
        return GrowerObject().project(from: grower)
    }
    
    static var growerFive: GrowerObject {
        var grower = Grower()
        grower.crops = [GrowerFivePlantedCrop]
        grower.growerID = "5"
        grower.zoneID = "WH 01"
        grower.firstName = "test"
        grower.lastName = "5"
        grower.plans = [planFive]
        return GrowerObject().project(from: grower)
    }
    
    static var growerSix: GrowerObject {
        var grower = Grower()
        grower.crops = [GrowerSixPlantedCrop]
        grower.growerID = "6"
        grower.zoneID = "WH 01"
        grower.firstName = "test"
        grower.lastName = "6"
        grower.plans = [planSix]
        return GrowerObject().project(from: grower)
    }
    
    static var growerSeven: GrowerObject {
        var grower = Grower()
        grower.crops = [GrowerSevenPlantedCrop]
        grower.growerID = "7"
        grower.zoneID = "WH 51"
        grower.firstName = "test"
        grower.lastName = "7"
        grower.plans = [planSeven]
        return GrowerObject().project(from: grower)
    }
    
    // MARK: Product Trigger Variables
    
    static var productTriggerOne: ProductTriggerObject {
        let productTrigger = ProductTriggerObject()
        productTrigger.productTriggerID = "1"
        productTrigger.zoneID = "RM 5"
        productTrigger.cropID = "1"
        productTrigger.triggerPrice = 8.11
        productTrigger.limitAcres = true
        productTrigger.ffMult = 1.37
        productTrigger.capMult = 1.2
        productTrigger.productsID = List<String>()
        productTrigger.productsID.append("1")
        productTrigger.type = "Threshold"
        productTrigger.parentProductsID = List<String>()
        return productTrigger
    }
    
    static var productTriggerTwo: ProductTriggerObject {
        let productTrigger = ProductTriggerObject()
        productTrigger.productTriggerID = "2"
        productTrigger.zoneID = "PNW 6"
        productTrigger.cropID = "2"
        productTrigger.triggerPrice = 24.00
        productTrigger.limitAcres = true
        productTrigger.ffMult = 1.37
        productTrigger.capMult = 1.2
        productTrigger.productsID = List<String>()
        productTrigger.productsID.append("2")
        productTrigger.productsID.append("3")
        productTrigger.type = "Threshold"
        productTrigger.parentProductsID = List<String>()
        return productTrigger
    }
    
    static var productTriggerThree: ProductTriggerObject {
        let productTrigger = ProductTriggerObject()
        productTrigger.productTriggerID = "3"
        productTrigger.zoneID = "SEC C"
        productTrigger.cropID = "3"
        productTrigger.triggerPrice = 15.04
        productTrigger.limitAcres = true
        productTrigger.ffMult = 1.6
        productTrigger.capMult = 1.2
        productTrigger.productsID = List<String>()
        productTrigger.productsID.append("4")
        productTrigger.type = "Threshold"
        productTrigger.parentProductsID = List<String>()
        return productTrigger
    }
    
    static var productTriggerFour: ProductTriggerObject {
        let productTrigger = ProductTriggerObject()
        productTrigger.productTriggerID = "4"
        productTrigger.zoneID = "SEC C"
        productTrigger.minimumRateUsed = RealmOptional<Double>(0.078125)
        productTrigger.cropID = "1"
        productTrigger.triggerPrice = 15.84
        productTrigger.limitAcres = true
        productTrigger.ffMult = 1.6
        productTrigger.capMult = 1.2
        productTrigger.productsID = List<String>()
        productTrigger.productsID.append("5")
        productTrigger.type = "Threshold"
        productTrigger.parentProductsID = List<String>()
        return productTrigger
    }
    
    static var productTriggerFive: ProductTriggerObject {
        let productTrigger = ProductTriggerObject()
        productTrigger.productTriggerID = "5"
        productTrigger.zoneID = "WH 01"
        productTrigger.cropID = "4"
        productTrigger.triggerPrice = 4.03
        productTrigger.limitAcres = false
        productTrigger.ffMult = 1.6
        productTrigger.capMult = 1.2
        productTrigger.productsID = List<String>()
        productTrigger.productsID.append("6")
        productTrigger.type = "Redemption"
        productTrigger.parentProductsID = List<String>()
        return productTrigger
    }
    
    static var productTriggerSix: ProductTriggerObject {
        let productTrigger = ProductTriggerObject()
        productTrigger.productTriggerID = "6"
        productTrigger.zoneID = "WH 01"
        productTrigger.cropID = "2"
        productTrigger.triggerPrice = 32.063
        productTrigger.limitAcres = false
        productTrigger.ffMult = 1.6
        productTrigger.capMult = 1.2
        productTrigger.productsID = List<String>()
        productTrigger.productsID.append("8")
        productTrigger.type = "Redemption"
        productTrigger.parentProductsID = List<String>()
        productTrigger.parentProductsID.append("7")
        return productTrigger
    }
    
    static var productTriggerSeven: ProductTriggerObject {
        let productTrigger = ProductTriggerObject()
        productTrigger.productTriggerID = "7"
        productTrigger.zoneID = "WH 51"
        productTrigger.areaMult = RealmOptional<Double>(1.1)
        productTrigger.cropID = "1"
        productTrigger.triggerPrice = 10
        productTrigger.limitAcres = false
        productTrigger.ffMult = 1.42
        productTrigger.capMult = 1.35
        productTrigger.productsID = List<String>()
        productTrigger.productsID.append("9")
        productTrigger.productsID.append("10")
        productTrigger.type = "Threshold"
        productTrigger.parentProductsID = List<String>()
        return productTrigger
    }
    
    static var testCrops = [soybeans, potato, cotton, sugarBeets]
    
    static var testProducts = [trivaPro, ridomilGoldSL, ridomilGoldCopper, taviumWVaporGrip, besiege, sequence, cruiserMaxxPotatoExtreme, revusTop, clarivaEliteBeans, avictaCompleteBeans]
    
    static var testProductTriggers = [productTriggerOne, productTriggerTwo, productTriggerThree, productTriggerFour, productTriggerFive, productTriggerSix, productTriggerSeven]
    
    static var testGrowers = [growerOne, growerTwo, growerThree, growerFour, growerFive, growerSix, growerSeven]
    
}
