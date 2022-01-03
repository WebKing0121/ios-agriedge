//
//  StaticDataEndpoint.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/27/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Moya
import RealmSwift

enum StaticDataEndpoint {
    case fetchStaticData(userID: String)
}

extension StaticDataEndpoint: BaseEndpoint, AccessTokenAuthorizable {
        
    var path: String {
        switch self {
        case .fetchStaticData:
            return "/staticData"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchStaticData:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchStaticData:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .fetchStaticData(let userID):
            return ["Content-Type": "application/json", "userID": "\(userID)"]
        }
    }
    
    var sampleData: Data {
        switch self {
        case .fetchStaticData:
            return FileReader.readDataFromJSONFile(filename: "GetStaticDataResponse")
        }
    }
    
    var persist: (([Codable]) -> Void)? {
        switch self {
        case .fetchStaticData:
            return { objects in
                var objectsToPersist = [Object]()
                
                for case let crop as Crop in objects {
                    objectsToPersist.append(CropObject().project(from: crop))
                }
                
                for case let zone as Zone in objects {
                    objectsToPersist.append(ZoneObject().project(from: zone))
                }

                for case let product as Product in objects {
                    objectsToPersist.append(ProductObject().project(from: product))
                }
                
                for case let seed as Seed in objects {
                    objectsToPersist.append(SeedObject().project(from: seed))
                }

                for case let productTrigger as ProductTrigger in objects {
                    objectsToPersist.append(ProductTriggerObject().project(from: productTrigger))
                }
                
                for case let specialist as Specialist in objects {
                    objectsToPersist.append(SpecialistObject().project(from: specialist))
                }
                
                DualPersistenceLayer().saveAll(of: objectsToPersist) { result in
                    switch result {
                    case .success:
                        log(info: "saved \(objectsToPersist.count) objects to Realm")
                    case .failure:
                        log(error: "Error Saving StaticData")
                    }
                }
            }
        }
    }
    
    var cleanPersist: (([Codable]) -> Void)? {
        switch self {
        case .fetchStaticData:
            return { codables in
                
                func cleanSaveAll<T: Object>(_ objects: [T], objectTypeDescription: String) {
                    DualPersistenceLayer().cleanSaveAll(of: objects) { result in
                        switch result {
                        case .success:
                            log(info: "clean saved \(objects.count) objects of type: \(objectTypeDescription) to Realm")
                        case .failure:
                            log(error: "Error Saving StaticData objects of type: \(objectTypeDescription)")
                        }
                    }
                }

                let crops = codables.compactMap { $0 as? Crop }
                let cropObjects = crops.map { CropObject().project(from: $0) }
                if !cropObjects.isEmpty {
                    cleanSaveAll(cropObjects, objectTypeDescription: "Crop")
                }

                let zones = codables.compactMap { $0 as? Zone }
                let zoneObjects = zones.map { ZoneObject().project(from: $0) }
                if !zoneObjects.isEmpty {
                    cleanSaveAll(zoneObjects, objectTypeDescription: "Zone")
                }

                let products = codables.compactMap { $0 as? Product }
                let productObjects = products.map { ProductObject().project(from: $0) }
                if !productObjects.isEmpty {
                    cleanSaveAll(productObjects, objectTypeDescription: "Product")
                }

                let seeds = codables.compactMap { $0 as? Seed }
                let seedObjects = seeds.map { SeedObject().project(from: $0) }
                if !seedObjects.isEmpty {
                    cleanSaveAll(seedObjects, objectTypeDescription: "Seed")
                }

                let productTriggers = codables.compactMap { $0 as? ProductTrigger }
                let productTriggerObjects = productTriggers.map { ProductTriggerObject().project(from: $0) }
                if !productTriggerObjects.isEmpty {
                    cleanSaveAll(productTriggerObjects, objectTypeDescription: "ProductTrigger")
                }
                
                let specialists = codables.compactMap { $0 as? Specialist }
                let specialistObjects = specialists.map { SpecialistObject().project(from: $0) }
                if !specialistObjects.isEmpty {
                    cleanSaveAll(specialistObjects, objectTypeDescription: "Specialist")
                }
            }
        }
    }
}
