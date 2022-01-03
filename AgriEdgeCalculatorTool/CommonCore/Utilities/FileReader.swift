//
//  FileReader.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 6/21/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Foundation

final class FileReader {
    
    static func readDataFromJSONFile(filename: String, bundle: Bundle = Bundle.main) -> Data {
        guard let path = bundle.path(forResource: filename, ofType: "json"),
            let dataString = try? String(contentsOfFile: path),
            let data = dataString.data(using: String.Encoding.utf8) else {
                return Data()
        }
        
        return data
    }
    
}
