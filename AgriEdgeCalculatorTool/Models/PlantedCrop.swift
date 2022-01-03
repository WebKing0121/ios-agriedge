//
//  PlantedCrop.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct PlantedCrop: Codable {
    var plantedCropID = ""
    var cropID = ""
    var plantedAcreage: Double = 0.0
    
    init(crop: Crop) {
        self.plantedCropID = UUID().uuidString
        self.cropID = crop.cropID
        self.plantedAcreage = 0.0
    }
    
    init(plantedCropObject: PlantedCropObject) {
        self.plantedCropID = UUID().uuidString
        self.cropID = plantedCropObject.cropID
        self.plantedAcreage = plantedCropObject.plantedAcreage
    }
    
    enum CodingKeys: String, CodingKey {
        case cropID
        case plantedAcreage
    }
    
}

@objcMembers
class PlantedCropObject: Object {
    dynamic var plantedCropID = ""
    dynamic var cropID = ""
    dynamic var plantedAcreage: Double = 0
    
    override static func primaryKey() -> String? {
        return "plantedCropID"
    }
    
    func project(from plantedCrop: PlantedCrop) -> Self {
        self.plantedCropID = UUID().uuidString
        self.cropID = plantedCrop.cropID
        self.plantedAcreage = plantedCrop.plantedAcreage
        return self
    }
}
