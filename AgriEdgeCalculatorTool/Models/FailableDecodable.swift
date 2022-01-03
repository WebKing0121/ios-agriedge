//
//  FailableDecodable.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 3/5/21.
//  Copyright © 2021 Syngenta. All rights reserved.
//

import Foundation

struct FailableDecodable<Base: Decodable>: Decodable {

    let base: Base?
    let decodingError: DecodingError?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            base = try container.decode(Base.self)
            decodingError = nil
        } catch {
            base = nil
            decodingError = error as? DecodingError
        }
    }
}
