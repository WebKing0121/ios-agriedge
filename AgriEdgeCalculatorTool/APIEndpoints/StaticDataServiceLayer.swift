//
//  StaticDataServiceLayer.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 8/5/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

class StaticDataLayer: ServiceLayer<StaticDataEndpoint> {
    
    func fetchStaticData(_ endpoint: StaticDataEndpoint, completion: @escaping (StaticDataServiceResult<String>) -> Void) {
        provider?.request(endpoint) { result in
            switch result {
            case let .success(response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    var decodingErrors = [DecodingError]()
                    
                    let cropsPath = "data.crops"
                    let wrappedCrops = try filteredResponse.map([FailableDecodable<Crop>].self, atKeyPath: cropsPath)
                    let crops = wrappedCrops.compactMap { $0.base }
                    let cropErrors = wrappedCrops.compactMap { $0.decodingError }
                    decodingErrors.append(contentsOf: cropErrors)
                    DecodingErrors.handleDecodingErrors(cropErrors, endpoint: "StaticData", path: cropsPath)
                    endpoint.cleanPersist?(crops)

                    let zonesPath = "data.zones"
                    let wrappedZones = try filteredResponse.map([FailableDecodable<Zone>].self, atKeyPath: zonesPath)
                    let zones = wrappedZones.compactMap { $0.base }
                    let zoneErrors = wrappedZones.compactMap { $0.decodingError }
                    decodingErrors.append(contentsOf: zoneErrors)
                    DecodingErrors.handleDecodingErrors(zoneErrors, endpoint: "StaticData", path: zonesPath)
                    endpoint.cleanPersist?(zones)

                    let productsPath = "data.products"
                    let wrappedProducts = try filteredResponse.map([FailableDecodable<Product>].self, atKeyPath: productsPath)
                    let products = wrappedProducts.compactMap { $0.base }
                    let productErrors = wrappedProducts.compactMap { $0.decodingError }
                    decodingErrors.append(contentsOf: productErrors)
                    DecodingErrors.handleDecodingErrors(productErrors, endpoint: "StaticData", path: productsPath)
                    endpoint.cleanPersist?(products)

                    let seedsPath = "data.seedProducts"
                    let wrappedSeeds = try filteredResponse.map([FailableDecodable<Seed>].self, atKeyPath: seedsPath)
                    let seeds = wrappedSeeds.compactMap { $0.base }
                    let seedErrors = wrappedSeeds.compactMap { $0.decodingError }
                    decodingErrors.append(contentsOf: seedErrors)
                    DecodingErrors.handleDecodingErrors(seedErrors, endpoint: "StaticData", path: seedsPath)
                    endpoint.cleanPersist?(seeds)

                    let productTriggersPath = "data.productTriggers"
                    let wrappedProductTriggers = try filteredResponse.map([FailableDecodable<ProductTrigger>].self, atKeyPath: productTriggersPath)
                    let productTriggers = wrappedProductTriggers.compactMap { $0.base }
                    let productTriggerErrors = wrappedProductTriggers.compactMap { $0.decodingError }
                    decodingErrors.append(contentsOf: productTriggerErrors)
                    DecodingErrors.handleDecodingErrors(productTriggerErrors, endpoint: "StaticData", path: productTriggersPath)
                    endpoint.cleanPersist?(productTriggers)
                    
                    let specialistsPath = "data.specialistEmails"
                    let wrappedSpecialists = try filteredResponse.map([FailableDecodable<Specialist>].self, atKeyPath: specialistsPath)
                    let specialists = wrappedSpecialists.compactMap { $0.base }
                    let specialistErrors = wrappedSpecialists.compactMap { $0.decodingError }
                    decodingErrors.append(contentsOf: specialistErrors)
                    DecodingErrors.handleDecodingErrors(specialistErrors, endpoint: "StaticData", path: specialistsPath)
                    endpoint.cleanPersist?(specialists)
                    
                    let zoneIDs = try filteredResponse.map([String].self, atKeyPath: "data.zoneIDs")
                    if let user = PersistenceLayer().fetch(UserObject.self)?.first {
                        PersistenceLayer().update(user, updates: {
                            (user: UserObject) in
                            user.allowedZones.removeAll()
                            zoneIDs.forEach({
                                user.allowedZones.append($0)
                            })
                        }, completion: { result in
                            switch result {
                            case .success:
                                log(info: "updated user with \(zoneIDs.count) zones")
                            case .failure(let error):
                                log(error: "error updating user with \(zoneIDs.count) zones: \(error)")
                            }
                        })
                    }
                    // Did we get here without any errors encountered?
                    if decodingErrors.isEmpty {
                        completion(.success)
                    } else {
                        completion(.successWithErrors)
                    }
                } catch let error {
                    let error = "error mapping data: \(error)"
                    log(error: error)
                    completion(.failure(error))
                }
            case let .failure(error):
                let error = "failure fetching data: \(error)"
                log(error: error)
                completion(.failure(error))
            }
        }
    }
    
}

enum StaticDataServiceResult<Result> {
    case success
    case successWithErrors
    case failure(String)
}
