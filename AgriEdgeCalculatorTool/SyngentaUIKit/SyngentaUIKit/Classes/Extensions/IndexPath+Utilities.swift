//
//  IndexPath+Utilities.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/8/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Foundation

extension IndexPath {
    
    public func isLastOf<T>(_ array: [T]) -> Bool {
        return self.row == array.count - 1
        
    }
}
