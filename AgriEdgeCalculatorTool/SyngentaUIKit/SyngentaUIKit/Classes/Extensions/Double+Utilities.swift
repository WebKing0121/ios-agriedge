//
//  Double+Utilities.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Foundation

extension Double {
    
    public func currencyString() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter.string(from: self as NSNumber) ?? String("\(self)")
    }
    
}
