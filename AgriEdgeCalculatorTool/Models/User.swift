//
//  User.swift
//  AgriEdgeCalculatorTool
//
//  Created by lloyd on 7/11/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

struct User {
    let userID: String
    let firstName: String
    let lastName: String
    let email: String
    let specialists: [Specialist]
    let allowedZones: [String]
    
    init(userObject: UserObject) {
        self.userID = userObject.userID
        self.firstName = userObject.firstName
        self.lastName = userObject.lastName
        self.email = userObject.email
        self.allowedZones = Array(userObject.allowedZones)
        self.specialists = Array(userObject.specialists).map({ Specialist(specialistObject: $0) })

    }

    init(userID: String, firstName: String, lastName: String, email: String, allowedZones: [String], specialists: [Specialist]) {
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.allowedZones = allowedZones
        self.specialists = specialists
    }
}

@objcMembers
class UserObject: Object {
    dynamic var userID = ""
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var email = ""
    let allowedZones = List<String>()
    let specialists = List<SpecialistObject>()
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    func project(from user: User) -> Self {
        self.userID = user.userID
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email
        
        user.allowedZones.forEach { zone in
            self.allowedZones.append(zone)
        }
        user.specialists.forEach { specialist in
            self.specialists.append(SpecialistObject().project(from: specialist))
        }
        return self
    }
}
