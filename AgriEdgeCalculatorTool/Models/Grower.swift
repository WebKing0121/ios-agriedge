//
//  Grower.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/17/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct Grower: Codable {
    var growerID = ""
    var zoneID = ""
    var farmName = ""
    var firstName: String?
    var lastName: String?
    var email: String?
    var phoneNumber: String?
    var userID = ""
    var source: GrowerSource = .userCreated
    var crops: [PlantedCrop]?
    var plans: [Plan]?
    
    var fullName: String {
        var fullName = "\(firstName ?? "") \(lastName ?? "")"
        if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            fullName = "\(email ?? "")"
        }
        return fullName
    }
        
    init(growerObject: GrowerObject) {
        self.growerID = growerObject.growerID
        self.firstName = growerObject.firstName
        self.lastName = growerObject.lastName
        self.zoneID = growerObject.zoneID
        self.farmName = growerObject.farmName
        self.email = growerObject.email
        self.phoneNumber = growerObject.phoneNumber
        self.userID = growerObject.userID
        self.source = GrowerSource(rawValue: growerObject.source) ?? .userCreated
        self.crops = Array(growerObject.crops).map({
            (crop: PlantedCropObject) -> PlantedCrop in
            return PlantedCrop(plantedCropObject: crop)
        })
        self.plans = Array(growerObject.plans).map({
            (planObject: PlanObject) -> Plan in
            return Plan(planObject: planObject)
        })
    }

    init() {
        guard let userData = PersistenceLayer().fetch(UserObject.self)?.first else { return }
        userID = User(userObject: userData).userID
        growerID = UUID().uuidString
    }
}

extension Grower {
    
    var totalPlantedAcreage: Double {
        return self.crops?.map({ $0.plantedAcreage }).reduce(0, +) ?? 0
    }
    
}

@objcMembers
class GrowerObject: Object {
    dynamic var growerID = ""
    dynamic var zoneID = ""
    dynamic var farmName = ""
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var email: String?
    dynamic var phoneNumber: String?
    dynamic var userID = ""
    dynamic var source = 1
    dynamic var shouldDelete = false
    let crops = List<PlantedCropObject>()
    let plans = List<PlanObject>()
    
    override static func primaryKey() -> String? {
        return "growerID"
    }
    
    func project(from grower: Grower, shouldCleanPlans: Bool = false) -> Self {
        self.growerID = grower.growerID
        self.farmName = grower.farmName
        self.zoneID = grower.zoneID
        self.firstName = grower.firstName ?? " "
        self.lastName = grower.lastName ?? " "
        self.email = grower.email ?? " "
        self.phoneNumber = grower.phoneNumber ?? " "
        self.userID = grower.userID
        self.source = grower.source.rawValue
        self.shouldDelete = false
        
        if shouldCleanPlans {
            // delete any existing planted crops and plans on the grower before persisting new ones
            let predicate = NSPredicate(format: "growerID = %@", grower.growerID)
            if let existingGrower = PersistenceLayer().fetch(GrowerObject.self, predicate: predicate)?.first {
                
                let plantedCropObjectsToDelete = Array(existingGrower.crops).map({ $0.plantedCropID })
                plantedCropObjectsToDelete.forEach({ plantedCropID in
                    let predicate = NSPredicate(format: "plantedCropID = %@", plantedCropID)
                    guard let plantedCrop = PersistenceLayer().fetch(PlantedCropObject.self, predicate: predicate)?.first else { return }
                    PersistenceLayer().delete(plantedCrop)
                })
                
                let planObjectsToDelete = Array(existingGrower.plans).map({ $0.planID })
                planObjectsToDelete.forEach({ planID in
                    let predicate = NSPredicate(format: "planID = %@", planID)
                    guard let plan = PersistenceLayer().fetch(PlanObject.self, predicate: predicate)?.first else { return }
                    PersistenceLayer().delete(plan)
                })
            }
        }
        
        grower.crops?.forEach({ plantedCrop in
            self.crops.append(PlantedCropObject().project(from: plantedCrop))
        })
        
        grower.plans?.forEach({ plan in
            self.plans.append(PlanObject().project(from: plan))
        })
        
        return self
    }
    
}

struct GrowersRequest: Encodable {
    var growers: [Grower]?
    
    init(growers: [Grower]) {
        self.growers = growers
    }
}

enum GrowerSource: Int, Codable {
    case userCreated = 1
    case salesforceImport = 2
}
