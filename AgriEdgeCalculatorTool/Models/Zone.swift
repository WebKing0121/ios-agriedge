//
//  Zone.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/24/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct Zone: Codable, NameSearchable {
    var zoneID = ""
    var displayName = ""
    
    init(zoneObject: ZoneObject) {
        self.zoneID = zoneObject.zoneID
        self.displayName = zoneObject.displayName
    }
}

@objcMembers
class ZoneObject: Object {
    
    dynamic var zoneID = ""
    dynamic var displayName = ""
    
    override static func primaryKey() -> String? {
        return "zoneID"
    }
    
    func project(from zone: Zone) -> Self {
        self.zoneID = zone.zoneID
        self.displayName = zone.displayName
        return self
    }

}

extension String {
    
    func zoneDisplayNameFromID() -> String? {
        let predicate = NSPredicate(format: "zoneID = %@", self)
        return PersistenceLayer().fetch(ZoneObject.self, predicate: predicate)?.first?.displayName
    }
    
}
