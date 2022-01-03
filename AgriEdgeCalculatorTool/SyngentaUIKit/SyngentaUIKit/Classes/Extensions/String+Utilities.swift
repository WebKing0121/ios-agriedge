//
//  String+Utilities.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/11/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

extension String {
    
    public func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    public func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    public func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    public func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    public func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    public mutating func telephoneFormat() -> String {
        let phoneNumberFormatCharacters: Set<Character> = ["(", ")", " ", "-"]
        self.removeAll(where: { phoneNumberFormatCharacters.contains($0) })
        switch self.count {
        case 0:
            self = "\(self)"
        case 1..<4:
            self = "(\(self)"
        case 4..<7:
            let paranthesisSubstring = self.substring(to: 3)
            let spaceSubstring = self.substring(from: 3)
            self = "(\(paranthesisSubstring)) \(spaceSubstring)"
        case 7..<11:
            let paranthesisSubstring = self.substring(to: 3)
            let spaceSubstring = self.substring(with: 3..<6)
            let dashSubstring = self.substring(from: 6)
            self = "(\(paranthesisSubstring)) \(spaceSubstring)-\(dashSubstring)"
        case _ where self.count > 10:
            let paranthesisSubstring = self.substring(to: 3)
            let spaceSubstring = self.substring(with: 3..<6)
            let dashSubstring = self.substring(with: 6..<10)
            self = "(\(paranthesisSubstring)) \(spaceSubstring)-\(dashSubstring)"
        default:
            break
        }
        return self
    }

}
