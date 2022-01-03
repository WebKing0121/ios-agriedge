//
//  RebateCalculator.swift
//  AgriEdgeCalculatorTool
//
//  Created by lloyd on 7/16/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

final class RebateCalculator {
    
    // MARK: - CropProtection rebate methods
    
    private func calculateTotalPriceFromCPApplications(in plan: Plan, from grower: Grower) -> Double {
        guard let productsFound = PersistenceLayer().fetch(ProductObject.self)?.map({ Product(productObject: $0) }) else {
            log(error: "Unable to Pull Products.")
            return 0.0
        }
        var totalPrice: Double = 0.0
        var productTriggersUsed = [SumOfProductTrigger]()
        plan.applications.forEach { application in
            guard let product = productsFound.filter({ $0.productID == application.productID }).first,
                let appliedAcreage = Double(application.appliedAcreage),
                let appliedRate = Double(application.appliedRate) else {
                    print("error code here for not having the correct product")
                    return
            }
            //              Price      *                Applied Total Amount
            totalPrice += (product.productID.productPriceFromID(zoneID: grower.zoneID) ?? 0.0)
                * appliedRate * appliedAcreage / application.appliedUoM.ratio
            
            let predicate = NSPredicate(format: "cropID = %@ AND zoneID = %@ AND type = \"\(ProductTriggerType.Redemption.rawValue)\"", application.cropID, grower.zoneID)
            if let productTriggerFound = PersistenceLayer().fetch(ProductTriggerObject.self, predicate: predicate) {
                productTriggerFound.forEach({ productTriggerObject in
                    let productTrigger = ProductTrigger(productTriggerObject: productTriggerObject)
                    if (productTrigger.minimumRateUsed ?? 0.0) <= (appliedRate / application.appliedUoM.ratio),
                    productTrigger.productsID.contains(application.productID) {
                        let calculatedAppliedAcreage = appliedAcreage / (productTrigger.areaMult ?? 1.0)
                        if productTriggersUsed.contains(where: { $0.productTrigger.productTriggerID == productTrigger.productTriggerID }),
                            let index = productTriggersUsed.firstIndex(where: { $0.productTrigger.productTriggerID == productTrigger.productTriggerID }) {
                            productTriggersUsed[index].appliedAcreage += calculatedAppliedAcreage
                            productTriggersUsed[index].basePricePerAcres += productTrigger.triggerPrice * appliedRate / application.appliedUoM.ratio
                            productTriggersUsed[index].fiftyFiftyPricePerAcres += productTrigger.triggerPrice * productTrigger.ffMult * appliedRate / application.appliedUoM.ratio
                            productTriggersUsed[index].capPricePerAcres += productTrigger.triggerPrice * productTrigger.ffMult * productTrigger.capMult * appliedRate / application.appliedUoM.ratio
                        } else {
                            let basePrice = productTrigger.triggerPrice * appliedRate / application.appliedUoM.ratio
                            let FFMPrice = productTrigger.triggerPrice * productTrigger.ffMult * appliedRate / application.appliedUoM.ratio
                            let capPrice = productTrigger.triggerPrice * productTrigger.ffMult * productTrigger.capMult * appliedRate / application.appliedUoM.ratio
                            var parentAcreage = [Double]()
                            if productTrigger.limitParentAcres {
                                productTrigger.parentsID?.forEach({ parentProductID in
                                    var maxAcres = 0.0
                                    plan.applications.filter({ $0.productID == parentProductID}).forEach { application in
                                        maxAcres = max(maxAcres, Double(application.appliedAcreage) ?? 0.0)
                                    }
                                    parentAcreage.append(maxAcres)
                                })
                            }
                            productTriggersUsed.append(SumOfProductTrigger(with: productTrigger, appliedAcreage: calculatedAppliedAcreage, basePricePerAcres: basePrice, fiftyFiftyPricePerAcres: FFMPrice, capPricePerAcres: capPrice, parentProductAcreage: parentAcreage))
                        }
                    }
                })
            }
        }
        
        productTriggersUsed.forEach { sumOfProductTrigger in
            var acreageToUse = sumOfProductTrigger.appliedAcreage
            sumOfProductTrigger.parentProductAcreage.forEach { parentAcreage in
                acreageToUse = min(sumOfProductTrigger.appliedAcreage, parentAcreage)
            }
            if sumOfProductTrigger.productTrigger.limitAcres,
                let plantedCrop = grower.crops?.first(where: { $0.cropID == sumOfProductTrigger.productTrigger.cropID}) {
                totalPrice += sumOfProductTrigger.basePricePerAcres * min(acreageToUse, plantedCrop.plantedAcreage)
            } else {
                totalPrice += sumOfProductTrigger.basePricePerAcres * acreageToUse
            }
        }
        return totalPrice
    }

    // Basic threshold determines the minimum value the TotalPrice needs to surpass in order to get a rebate
    private func calculateBasicThresholdFromCPApplications(in plan: Plan, from grower: Grower) -> (Double, Double, Double) {
        guard let cropsFound = PersistenceLayer().fetch(CropObject.self)?.map({ Crop(cropObject: $0) }) else {
            log(error: "Unable to Pull Crops List.")
            return (0.0, 0.0, 0.0)
        }
        
        // First Portion of the Threshhold is based against how much the grower has grown
        var basicFoundThreshhold = 0.0
        var ffMFoundThreshhold = 0.0
        var capFoundThreshhold = 0.0
        grower.crops?.forEach({ crop in
            guard let cropFound = cropsFound.filter({ $0.cropID == crop.cropID }).first else {
                return
            }
            let price = cropFound.zonePrice[grower.zoneID] ?? 0.0
            let ffMult = cropFound.FFMult[grower.zoneID] ?? 1.0
            let capMult = cropFound.CapMult[grower.zoneID] ?? 1.0
            basicFoundThreshhold += price * crop.plantedAcreage
            ffMFoundThreshhold += price * crop.plantedAcreage * ffMult
            capFoundThreshhold += price * crop.plantedAcreage * ffMult * capMult
        })
        var productTriggersUsed = [SumOfProductTrigger]()

        // Second Portion of the Threshhold is based against certian business Rules with certian Crops
        plan.applications.forEach { application in
            guard let appliedAcreage = Double(application.appliedAcreage),
                let appliedRate = Double(application.appliedRate) else {
                    return
            }
            let predicate = NSPredicate(format: "cropID = %@ AND zoneID = %@ AND type = \"\(ProductTriggerType.Threshold.rawValue)\"", application.cropID, grower.zoneID)
            if let productTriggerFound = PersistenceLayer().fetch(ProductTriggerObject.self, predicate: predicate) {
                productTriggerFound.forEach({ productTriggerObject in
                    let productTrigger = ProductTrigger(productTriggerObject: productTriggerObject)
                    if (productTrigger.minimumRateUsed ?? 0.0) <= (appliedRate / application.appliedUoM.ratio),
                        productTrigger.productsID.contains(application.productID) {
                        let calculatedAppliedAcreage = appliedAcreage / (productTrigger.areaMult ?? 1.0)
                        if productTriggersUsed.contains(where: { $0.productTrigger.productTriggerID == productTrigger.productTriggerID }),
                            let index = productTriggersUsed.firstIndex(where: { $0.productTrigger.productTriggerID == productTrigger.productTriggerID }) {
                            productTriggersUsed[index].appliedAcreage += calculatedAppliedAcreage
                        } else {
                            let basePrice = productTrigger.triggerPrice
                            let ffMPrice = productTrigger.triggerPrice * productTrigger.ffMult
                            let capPrice = productTrigger.triggerPrice * productTrigger.ffMult * productTrigger.capMult
                            var parentAcreage = [Double]()
                            if productTrigger.limitParentAcres {
                                productTrigger.parentsID?.forEach({ parentProductID in
                                    var maxAcres = 0.0
                                    plan.applications.filter({ $0.productID == parentProductID}).forEach { application in
                                        maxAcres = max(maxAcres, Double(application.appliedAcreage) ?? 0.0)
                                    }
                                    parentAcreage.append(maxAcres)
                                })
                            }
                            productTriggersUsed.append(SumOfProductTrigger(with: productTrigger, appliedAcreage: calculatedAppliedAcreage, basePricePerAcres: basePrice, fiftyFiftyPricePerAcres: ffMPrice, capPricePerAcres: capPrice, parentProductAcreage: parentAcreage))
                        }
                    }
                })
            }
        }
        productTriggersUsed.forEach { sumOfProductTrigger in
            var acreageToUse = sumOfProductTrigger.appliedAcreage
            sumOfProductTrigger.parentProductAcreage.forEach { parentAcreage in
                acreageToUse = min(sumOfProductTrigger.appliedAcreage, parentAcreage)
            }
            if sumOfProductTrigger.productTrigger.limitAcres,
                let plantedCrop = grower.crops?.first(where: { $0.cropID == sumOfProductTrigger.productTrigger.cropID}) {
                basicFoundThreshhold += sumOfProductTrigger.basePricePerAcres * min(acreageToUse, plantedCrop.plantedAcreage)
                ffMFoundThreshhold += sumOfProductTrigger.fiftyFiftyPricePerAcres * min(acreageToUse, plantedCrop.plantedAcreage)
                capFoundThreshhold += sumOfProductTrigger.capPricePerAcres * min(acreageToUse, plantedCrop.plantedAcreage)
            } else {
                basicFoundThreshhold += sumOfProductTrigger.basePricePerAcres * acreageToUse
                ffMFoundThreshhold += sumOfProductTrigger.fiftyFiftyPricePerAcres * acreageToUse
                capFoundThreshhold += sumOfProductTrigger.capPricePerAcres * acreageToUse
            }
        }
        // Return the additive of both
        return (basicFoundThreshhold, ffMFoundThreshhold, capFoundThreshhold)
    }

    private func calculateCPApplicationRebate(from plan: Plan, for grower: Grower) -> RebatePortion {
        // Ensure we have at least 2 applications for this plan before showing critical information
        guard plan.applications.count > 1 else { return RebatePortion() }
        
        let totalSpent = calculateTotalPriceFromCPApplications(in: plan, from: grower)
        let thresholds = calculateBasicThresholdFromCPApplications(in: plan, from: grower)
        let fiftyFiftyMultiplier = 0.50
        let tenNinetyMultiplier = 0.10
        let totalSpentPerAcre: Double = totalSpent / (grower.crops?.map({ $0.plantedAcreage }).reduce(0, +) ?? 1.0)

        var estimatedRebate = 0.0
        let cropsuranceTenNinety = thresholds.0
        let targetFiftyFifty = thresholds.1
        let riskManagementCap = thresholds.2
        // Get all variations of the threshholds, grouped by ranges
        switch totalSpent {
        case cropsuranceTenNinety..<targetFiftyFifty:
            estimatedRebate = (totalSpent - cropsuranceTenNinety) * tenNinetyMultiplier
        case targetFiftyFifty..<riskManagementCap:
            let difference = (totalSpent - cropsuranceTenNinety) * tenNinetyMultiplier
            let difference2 = (totalSpent - targetFiftyFifty) * fiftyFiftyMultiplier
            if difference <= difference2 {
                estimatedRebate = difference2
            } else {
                estimatedRebate = difference
            }
        case _ where totalSpent > riskManagementCap:
            let difference = (riskManagementCap - cropsuranceTenNinety) * tenNinetyMultiplier
            let difference2 = (riskManagementCap - targetFiftyFifty) * fiftyFiftyMultiplier
            if difference <= difference2 {
                estimatedRebate = difference2
            } else {
                estimatedRebate = difference
            }
        default:
            break
        }
        
        return RebatePortion(estimatedRebateTotal: estimatedRebate,
                             cropsurance: cropsuranceTenNinety,
                             target: targetFiftyFifty,
                             capRiskManagement: riskManagementCap,
                             estimatedSpend: totalSpent,
                             estimatedSpendPerAcre: totalSpentPerAcre)
    }
    
    // MARK: - Seed rebate methods
    
    private func calculateTotalPriceFromSeedApplications(in plan: Plan, from grower: Grower) -> Double {
        var totalPrice: Double = 0.0
        plan.seedApplications.forEach { seedApplication in
            guard let appliedRate = Double(seedApplication.appliedRate),
                let appliedAcreage = Double(seedApplication.appliedAcreage) else {
                    print("error code here for not having the correct seed")
                    return
            }
            // Calculate price of this seedApplication
            var totalSeedInBags = appliedRate * appliedAcreage //this value is in selected unit (seeds/kernels OR bags)
            if seedApplication.appliedUoM != .bag { //if seed/kernel, we need to convert it
                totalSeedInBags = totalSeedInBags / seedApplication.seedID.seedStdFactorFromID() //convert to .bags
            }
            // price = price in bags * Applied Total Amount in bags
            let price = (seedApplication.seedID.seedPriceFromID(zoneID: grower.zoneID) ?? 0.0) * totalSeedInBags
            totalPrice += price
        }
        return totalPrice
    }

    // Basic threshold determines the minimum value the TotalPrice needs to surpass in order to get a rebate
    private func calculateBasicThresholdForSeeds(in plan: Plan, from grower: Grower) -> (Double, Double, Double) {
        guard let cropsFound = PersistenceLayer().fetch(CropObject.self)?.map({ Crop(cropObject: $0) }) else {
            log(error: "Unable to Pull Crops List.")
            return (0.0, 0.0, 0.0)
        }
        
        // First Portion of the Threshhold is based against how much the grower has grown
        var cropsuranceThreshold = 0.0
        var targetThreshold = 0.0
        var capThreshold = 0.0
        grower.crops?.forEach({ crop in
            guard let cropFound = cropsFound.filter({ $0.cropID == crop.cropID }).first else {
                return
            }
            
            let price = cropFound.seedZonePrice?[grower.zoneID] ?? 0.0
            let ffMult = cropFound.seedFFMult?[grower.zoneID] ?? 1.0
            let capMult = cropFound.seedCapMult?[grower.zoneID] ?? 1.0
            cropsuranceThreshold += price * crop.plantedAcreage
            targetThreshold += price * crop.plantedAcreage * ffMult
            capThreshold += price * crop.plantedAcreage * ffMult * capMult
        })

        return (cropsuranceThreshold, targetThreshold, capThreshold)
    }
    
    private func calculateSeedApplicationRebate(from plan: Plan, for grower: Grower) -> RebatePortion {
        
        // Ensure we have at least 2 seed applications for this plan before showing critical information
        // TODO: Add the && false below to short-circuit seed rebate calculations. They may be permanently
        //  removed in the near future
        guard plan.seedApplications.count > 1 && false else {
            // Return a zero rebate
            return RebatePortion(estimatedRebateTotal: 0, cropsurance: 0, target: 0, capRiskManagement: 0, estimatedSpend: 0, estimatedSpendPerAcre: 0)
        }

        let totalSpent = calculateTotalPriceFromSeedApplications(in: plan, from: grower)
        let thresholds = calculateBasicThresholdForSeeds(in: plan, from: grower)
        let twentyEightyMultiplier = 0.20
        let fiveNinetyFiveMultiplier = 0.05
        let totalSpentPerAcre: Double = totalSpent / (grower.crops?.map({ $0.plantedAcreage }).reduce(0, +) ?? 1.0)

        var estimatedRebate = 0.0
        let threshold1 = thresholds.0
        let threshold2 = thresholds.1
        let threshold3 = thresholds.2
        // Get all variations of the threshholds, grouped by ranges
        switch totalSpent {
        case threshold1..<threshold2:
            estimatedRebate = (totalSpent - threshold1) * fiveNinetyFiveMultiplier
        case threshold2..<threshold3:
            let difference = (totalSpent - threshold1) * fiveNinetyFiveMultiplier
            let difference2 = (totalSpent - threshold2) * twentyEightyMultiplier
            if difference <= difference2 {
                estimatedRebate = difference2
            } else {
                estimatedRebate = difference
            }
        case _ where totalSpent > threshold3:
            let difference = (threshold3 - threshold1) * fiveNinetyFiveMultiplier
            let difference2 = (threshold3 - threshold2) * twentyEightyMultiplier
            if difference <= difference2 {
                estimatedRebate = difference2
            } else {
                estimatedRebate = difference
            }
        default:
            break
        }
        
        return RebatePortion(estimatedRebateTotal: estimatedRebate,
                             cropsurance: threshold1,
                             target: threshold2,
                             capRiskManagement: threshold3,
                             estimatedSpend: totalSpent,
                             estimatedSpendPerAcre: totalSpentPerAcre)
    }
    
    private func calculateAgriClimePrice(from plan: Plan, for grower: Grower) -> Double? {
        var agriClimeCost: Double?
        for cpApplication in plan.applications where cpApplication.enrollInAgriClime == 1 {
            guard let agriClimeEnrolledQuantityString = cpApplication.agriClimeQuantity,
                  let agriClimeEnrolledQuantity = Double(agriClimeEnrolledQuantityString),
                  let agriClimeProductCostPerUnit = cpApplication.productID.agriClimeZonePriceFromID(zoneID: grower.zoneID) else {
                continue
            }
            agriClimeCost = (agriClimeCost ?? 0) +
                agriClimeEnrolledQuantity * agriClimeProductCostPerUnit * 0.03 //3% of redemptionPrice * volume
        }
        return agriClimeCost
    }
    
    // MARK: - Public methods
    
    func calculateRebate(from plan: Plan, for grower: Grower) -> Rebate {
        let cpRebatePortion = calculateCPApplicationRebate(from: plan, for: grower)
        let seedRebatePortion = calculateSeedApplicationRebate(from: plan, for: grower)
        var totalRebate = cpRebatePortion.estimatedRebateTotal + seedRebatePortion.estimatedRebateTotal
        let agriClimeCost = calculateAgriClimePrice(from: plan, for: grower)
        if let agriClimeCost = agriClimeCost {
            totalRebate -= agriClimeCost
        }
        totalRebate = max(totalRebate, 0) //don't allow negative values
        return Rebate(cpEstimatedRebateTotal: cpRebatePortion.estimatedRebateTotal.currencyString(),
                      cpTenNinetyCropsurance: cpRebatePortion.cropsurance.currencyString(),
                      cpFiftyFiftyTarget: cpRebatePortion.target.currencyString(),
                      cpCapRiskManagement: cpRebatePortion.capRiskManagement.currencyString(),
                      cpEstimatedSpend: cpRebatePortion.estimatedSpend.currencyString(),
                      cpEstimatedSpendPerAcre: cpRebatePortion.estimatedSpendPerAcre.currencyString(),
                      seedEstimatedRebateTotal: seedRebatePortion.estimatedRebateTotal.currencyString(),
                      seedFiveNinetyFiveCropsurance: seedRebatePortion.cropsurance.currencyString(),
                      seedTwentyEightyTarget: seedRebatePortion.target.currencyString(),
                      seedCapRiskManagement: seedRebatePortion.capRiskManagement.currencyString(),
                      seedEstimatedSpend: seedRebatePortion.estimatedSpend.currencyString(),
                      seedEstimatedSpendPerAcre: seedRebatePortion.estimatedSpendPerAcre.currencyString(),
                      agriClimeCost: agriClimeCost?.currencyString(),
                      totalEstimatedRebateTotal: totalRebate.currencyString())
    }
}

struct SumOfProductTrigger {
    var productTrigger: ProductTrigger
    var appliedAcreage: Double
    var basePricePerAcres: Double
    var fiftyFiftyPricePerAcres: Double
    var capPricePerAcres: Double
    var parentProductAcreage: [Double]
    
    init(with productTrigger: ProductTrigger, appliedAcreage: Double, basePricePerAcres: Double, fiftyFiftyPricePerAcres: Double, capPricePerAcres: Double, parentProductAcreage: [Double]) {
        self.productTrigger = productTrigger
        self.appliedAcreage = appliedAcreage
        self.basePricePerAcres = basePricePerAcres
        self.fiftyFiftyPricePerAcres = fiftyFiftyPricePerAcres
        self.capPricePerAcres = capPricePerAcres
        self.parentProductAcreage = parentProductAcreage
    }
}

private struct RebatePortion {
    var estimatedRebateTotal = 0.0
    var cropsurance = 0.0
    var target = 0.0
    var capRiskManagement = 0.0
    var estimatedSpend = 0.0
    var estimatedSpendPerAcre = 0.0
}
