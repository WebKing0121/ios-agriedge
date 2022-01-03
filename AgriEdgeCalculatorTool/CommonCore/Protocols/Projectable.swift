//
//  Projectable.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/1/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import RealmSwift

protocol Projectable: AnyObject {
    func project(from object: Codable) -> Self
}

extension Projectable {
    
    func project(from object: Codable) -> Self {
        return self
    }
    
}

extension Object: Projectable { }
