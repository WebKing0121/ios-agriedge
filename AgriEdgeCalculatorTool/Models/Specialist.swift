//
//  Specialist.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 8/16/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct Specialist: Codable {
    let specialistID: String
    let email: String
    
    init(specialistObject: SpecialistObject) {
        self.specialistID = specialistObject.specialistID
        self.email = specialistObject.email
    }
    
    init(specialistID: String, email: String) {
        self.specialistID = specialistID
        self.email = email
    }
}

@objcMembers
class SpecialistObject: Object {
    dynamic var specialistID = ""
    dynamic var email = ""
    
    override static func primaryKey() -> String? {
        return "specialistID"
    }
    
    func project(from specialist: Specialist) -> Self {
        self.specialistID = specialist.specialistID
        self.email = specialist.email
        return self
    }
}
