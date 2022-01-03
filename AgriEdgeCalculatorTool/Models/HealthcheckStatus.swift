//
//  HealthcheckStatus.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 8/7/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

struct HealthcheckStatus: Codable {
    var api = ""
    var db = ""
    
    var isAPIHealthy: Bool {
        return (api == "RUNNING" && db == "RUNNING")
    }
}
