//
//  DataUploading.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/24/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

protocol DataUploading {
    func updateData()
    func uploadGrowers()
    func deleteGrowers()
    func uploadPlans()
    func deletePlans()
}

extension DataUploading {
    
    func updateData() {
        guard !DualPersistenceLayer(configuration: .update).isRealmEmpty else { return }
        uploadGrowers()
        deleteGrowers()
        uploadPlans()
        deletePlans()
    }
    
    func uploadGrowers() {
        guard !DualPersistenceLayer(configuration: .update).isRealmEmpty else { return }
        guard let growerObjects = DualPersistenceLayer(configuration: .update).fetch(GrowerObject.self),
            growerObjects.count > 0 else {
                log(error: "no grower objects found in realm to upload")
                return
        }
        
        log(info: "found \(growerObjects.count) growers in realm to upload")
        
        let growers = growerObjects.filter({ $0.shouldDelete == false }).map {
            (growerObject: GrowerObject) -> Grower in
            
            return Grower(growerObject: growerObject)
        }
        let userID = PersistenceLayer().fetch(UserObject.self)?.first?.userID ?? ""
        let growersRequest = GrowersRequest(growers: growers)
        
        OktaSessionManager.shared.refreshTokensIfNeeded {
            ServiceLayer().create(GrowersEndpoint.createGrowers(userID: userID, growers: growersRequest)) {
                (result: ServiceResult<Any>) in
                switch result {
                case .success:
                    log(info: "sucessfully sent growers \(growers)")
                    DualPersistenceLayer(configuration: .update).deleteAll(of: GrowerObject.self)
                    DualPersistenceLayer(configuration: .update).deleteAll(of: PlantedCropObject.self)
                    DualPersistenceLayer(configuration: .update).deleteAll(of: RebateObject.self)
                case .failure:
                    log(error: "error sending growers \(growers)")
                }
            }
        }
    }
    
    func deleteGrowers() {
        guard !DualPersistenceLayer(configuration: .update).isRealmEmpty else { return }
        guard let growerObjects = DualPersistenceLayer(configuration: .update).fetch(GrowerObject.self),
            growerObjects.count > 0 else {
                log(error: "no grower objects found in realm to delete")
                return
        }
        log(info: "found \(growerObjects.count) growers in realm to delete")
        
        let filteredGrowersObject = growerObjects.filter({ $0.shouldDelete == true })
        let userID = PersistenceLayer().fetch(UserObject.self)?.first?.userID ?? ""
        
        OktaSessionManager.shared.refreshTokensIfNeeded {
            filteredGrowersObject.forEach { growerObject in
                ServiceLayer().create(GrowersEndpoint.deleteGrower(userID: userID, growerID: growerObject.growerID)) { (result: ServiceResult<Any>) in
                    switch result {
                    case .success:
                        log(info: "sucessfully deleted grower \(growerObject)")
                        growerObject.crops.forEach({ plantedCropObject in
                            DualPersistenceLayer(configuration: .update).delete(plantedCropObject)
                        })
                        DualPersistenceLayer(configuration: .update).delete(growerObject)
                        
                    case .failure:
                        log(error: "error deleting grower \(growerObject)")
                    }
                }
            }
        }
    }
    
    func uploadPlans() {
        guard !DualPersistenceLayer(configuration: .update).isRealmEmpty else { return }
        guard let planObjects = DualPersistenceLayer(configuration: .update).fetch(PlanObject.self),
            planObjects.count > 0 else {
                log(error: "no plan objects found in realm to upload")
                return
        }
        log(info: "found \(planObjects.count) plans in realm to upload")
        let plans = planObjects.filter({ $0.shouldDelete == false }).map { (planObject: PlanObject) in
            return Plan(planObject: planObject)
        }
        
        OktaSessionManager.shared.refreshTokensIfNeeded {
            for (index, plan) in plans.enumerated() {
                ServiceLayer().create(PlansEndpoint.createPlan(plan: plan)) {
                    (result: ServiceResult<Any>) in
                    switch result {
                    case .success:
                        log(info: "sucessfully sent plan \(plan)")
                        if let rebateObject = planObjects[index].rebate {
                            DualPersistenceLayer(configuration: .update).delete(rebateObject)
                        }
                        planObjects[index].applications.forEach({ DualPersistenceLayer(configuration: .update).delete($0) })
                        DualPersistenceLayer(configuration: .update).delete(planObjects[index])
                    case .failure:
                        log(error: "error sending plan \(plan)")
                    }
                }
            }
        }
    }
    
    func deletePlans() {
        guard !DualPersistenceLayer(configuration: .update).isRealmEmpty else { return }
        guard let planObjects = DualPersistenceLayer(configuration: .update).fetch(PlanObject.self),
            planObjects.count > 0 else {
                log(error: "no plan objects found in realm to delete")
                return
        }
        log(info: "found \(planObjects.count) plans in realm to delete")
        let filteredPlanObject = planObjects.filter({ $0.shouldDelete == true })
        let userID = PersistenceLayer().fetch(UserObject.self)?.first?.userID ?? ""
        
        OktaSessionManager.shared.refreshTokensIfNeeded {
            filteredPlanObject.forEach { planObject in
                ServiceLayer().create(PlansEndpoint.deletePlan(planID: planObject.planID, userID: userID)) { (result: ServiceResult<Any>) in
                    switch result {
                    case .success:
                        log(info: "sucessfully deleted plan \(planObject)")
                        planObject.applications.forEach({ application in
                            DualPersistenceLayer(configuration: .update).delete(application)
                        })
                        DualPersistenceLayer(configuration: .update).delete(planObject)
                        
                    case .failure:
                        log(error: "error deleting plan \(planObject)")
                    }
                }
            }
        }
    }
    
}
