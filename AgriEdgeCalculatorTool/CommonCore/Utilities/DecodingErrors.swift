//
//  DecodingErrors.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 3/14/21.
//  Copyright © 2021 Syngenta. All rights reserved.
//

import Foundation

struct DecodingErrors {
    static func handleDecodingErrors(_ decodingErrors: [DecodingError], endpoint: String, path: String) {
        guard let firstError = decodingErrors.first else { return }
        // Log all errors
        decodingErrors.forEach { decodingError in
            log(error: formatErrorMessage(decodingError: decodingError, endpoint: endpoint, path: path))
        }
        // Send only first error to NewRelic for easier debugging
        let errorMessage = formatErrorMessage(decodingError: firstError, endpoint: endpoint, path: path)
        let attributes = ["endpoint": endpoint, "path": path, "errorMessage": errorMessage]
        NewRelic.recordError(firstError, attributes: attributes)
    }
    
    private static func formatErrorMessage(decodingError: DecodingError, endpoint: String, path: String) -> String {
        let errorMessage: String
        switch decodingError {
        case .typeMismatch(_, let value):
            errorMessage = "\(value)"
        case .valueNotFound(_, let value):
            errorMessage = "\(value)"
        case .keyNotFound(_, let value):
            errorMessage = "\(value)"
        case .dataCorrupted(let key):
            errorMessage = "\(key)"
        default:
            errorMessage = decodingError.localizedDescription
        }
        return "\(endpoint) DecodingError for path: \(path): \(errorMessage)"
    }

}
