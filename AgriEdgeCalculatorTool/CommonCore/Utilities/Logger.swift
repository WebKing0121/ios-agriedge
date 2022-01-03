//
//  Logger.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/11/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

// Temporary logging mechanism until we implement a proper logging API
public func log(error message: String) {
    print("[Log Error]: \(message)")
}

public func log(info message: String) {
    print("[Log Info]: \(message)")
}
