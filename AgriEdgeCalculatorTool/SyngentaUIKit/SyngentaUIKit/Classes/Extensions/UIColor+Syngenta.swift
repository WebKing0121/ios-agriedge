//
//  UIColor+Syngenta.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/10/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: Hex Value Initializer
    
    public convenience init(color: Color, alpha: CGFloat = 1.0) {
        var colorString: String = color.hexValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if colorString.hasPrefix("#") {
            colorString.remove(at: colorString.startIndex)
        }
        
        if colorString.count != 6 {
            self.init(white: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: colorString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    // MARK: Design System Colors
    // https://digitial-product-engineering.atlassian.net/wiki/spaces/DS/pages/26738712/Color
    
    public static var teal100: UIColor {
        return UIColor(color: .teal100)
    }

    public static var teal300: UIColor {
        return UIColor(color: .teal300)
    }
    
    public static var teal500: UIColor {
        return UIColor(color: .teal500)
    }
    
    public static var teal700: UIColor {
        return UIColor(color: .teal700)
    }

    public static var neutral100: UIColor {
        return UIColor(color: .neutral100)
    }
    
    public static var neutral300: UIColor {
        return UIColor(color: .neutral300)
    }
    
    public static var neutral500: UIColor {
        return UIColor(color: .neutral500)
    }
    
    public static var neutral700: UIColor {
        return UIColor(color: .neutral700)
    }

    public static var solidWhite: UIColor {
        return UIColor(color: .solidWhite)
    }
    
    public static var ink300: UIColor {
        return UIColor(color: .ink300)
    }
    
    public static var ink700: UIColor {
        return UIColor(color: .ink700)
    }
    
    public static var ink900: UIColor {
        return UIColor(color: .ink900)
    }
    
    public static var green100: UIColor {
        return UIColor(color: .green100)
    }
    
    public static var green300: UIColor {
        return UIColor(color: .green300)
    }
    
    public static var green500: UIColor {
        return UIColor(color: .green500)
    }
    
    public static var green700: UIColor {
        return UIColor(color: .green700)
    }

    public static var orange100: UIColor {
        return UIColor(color: .orange100)
    }
    
    public static var orange300: UIColor {
        return UIColor(color: .orange300)
    }
    
    public static var orange500: UIColor {
        return UIColor(color: .orange500)
    }
    
    public static var orange700: UIColor {
        return UIColor(color: .orange700)
    }
    
    public static var red100: UIColor {
        return UIColor(color: .red100)
    }
    
    public static var red300: UIColor {
        return UIColor(color: .red300)
    }
    
    public static var red500: UIColor {
        return UIColor(color: .red500)
    }
    
    public static var red700: UIColor {
        return UIColor(color: .red700)
    }
    
    public static var blue100: UIColor {
        return UIColor(color: .blue100)
    }
    
    public static var blue300: UIColor {
        return UIColor(color: .blue300)
    }
    
    public static var blue500: UIColor {
        return UIColor(color: .blue500)
    }
    
    public static var blue700: UIColor {
        return UIColor(color: .blue700)
    }

    public static var purple100: UIColor {
        return UIColor(color: .purple100)
    }
    
    public static var purple300: UIColor {
        return UIColor(color: .purple300)
    }
    
    public static var purple500: UIColor {
        return UIColor(color: .purple500)
    }
    
    public static var purple700: UIColor {
        return UIColor(color: .purple700)
    }
    
    public static var yellow100: UIColor {
        return UIColor(color: .yellow100)
    }
    
    public static var yellow300: UIColor {
        return UIColor(color: .yellow300)
    }
    
    public static var yellow500: UIColor {
        return UIColor(color: .yellow500)
    }
    
    public static var yellow700: UIColor {
        return UIColor(color: .yellow700)
    }

}

public enum Color: CaseIterable {
    case teal100
    case teal300
    case teal500
    case teal700
    case neutral100
    case neutral300
    case neutral500
    case neutral700
    case solidWhite
    case ink300
    case ink700
    case ink900
    case green100
    case green300
    case green500
    case green700
    case orange100
    case orange300
    case orange500
    case orange700
    case red100
    case red300
    case red500
    case red700
    case blue100
    case blue300
    case blue500
    case blue700
    case purple100
    case purple300
    case purple500
    case purple700
    case yellow100
    case yellow300
    case yellow500
    case yellow700
}

public extension Color {
    
    var hexValue: String {
        switch self {
        case .teal100:
            return "#F2FDF9"
        case .teal300:
            return "#D8F3E9"
        case .teal500:
            return "#238661"
        case .teal700:
            return "#15563E"
        case .neutral100:
            return "#FAFBFC"
        case .neutral300:
            return "#F6F7F9"
        case .neutral500:
            return "#DFE2E7"
        case .neutral700:
            return "#CCD0D7"
        case .solidWhite:
            return "#FFFFFF"
        case .ink300:
            return "#BDC4D1"
        case .ink700:
            return "#5C6575"
        case .ink900:
            return "#171B27"
        case .green100:
            return "#F4F9F0"
        case .green300:
            return "#DFEFD2"
        case .green500:
            return "#72B040"
        case .green700:
            return "#345E13"
        case .orange100:
            return "#FDF7F2"
        case .orange300:
            return "#FCE8D9"
        case .orange500:
            return "#F28838"
        case .orange700:
            return "#9E5015"
        case .red100:
            return "#FEF6F6"
        case .red300:
            return "#FAE1E0"
        case .red500:
            return "#EC3B35"
        case .red700:
            return "#AF1D18"
        case .blue100:
            return "#F1F5FD"
        case .blue300:
            return "#D9E3F7"
        case .blue500:
            return "#3666C4"
        case .blue700:
            return "#113883"
        case .purple100:
            return "#F8F7FD"
        case .purple300:
            return "#E4DFF6"
        case .purple500:
            return "#6A4CD5"
        case .purple700:
            return "#371E8F"
        case .yellow100:
            return "#FEF9EB"
        case .yellow300:
            return "#FCECBA"
        case .yellow500:
            return "#F6CA46"
        case .yellow700:
            return "#836407"
        }
    }
    
    var name: String {
        switch self {
        case .teal100:
            return "Teal 100"
        case .teal300:
            return "Teal 300"
        case .teal500:
            return "Teal 500"
        case .teal700:
            return "Teal 700"
        case .neutral100:
            return "Neutral 100"
        case .neutral300:
            return "Neutral 300"
        case .neutral500:
            return "Neutral 500"
        case .neutral700:
            return "Neutral 700"
        case .solidWhite:
            return "White"
        case .ink300:
            return "Ink 300"
        case .ink700:
            return "Ink 700"
        case .ink900:
            return "Ink 900"
        case .green100:
            return "Green 100"
        case .green300:
            return "Green 300"
        case .green500:
            return "Green 500"
        case .green700:
            return "Green 700"
        case .orange100:
            return "Orange 100"
        case .orange300:
            return "Orange 300"
        case .orange500:
            return "Orange 500"
        case .orange700:
            return "Orange 700"
        case .red100:
            return "Red 100"
        case .red300:
            return "Red 300"
        case .red500:
            return "Red 500"
        case .red700:
            return "Red 700"
        case .blue100:
            return "Blue 100"
        case .blue300:
            return "Blue 300"
        case .blue500:
            return "Blue 500"
        case .blue700:
            return "Blue 700"
        case .purple100:
            return "Purple 100"
        case .purple300:
            return "Purple 300"
        case .purple500:
            return "Purple 500"
        case .purple700:
            return "Purple 700"
        case .yellow100:
            return "Yellow 100"
        case .yellow300:
            return "Yellow 300"
        case .yellow500:
            return "Yellow 500"
        case .yellow700:
            return "Yellow 700"
        }
    }
    
}

// MARK: - SemanticCustomColor

public enum SemanticCustomColor: String {
    case primaryInk
    case secondaryInk
    case tableBackground
    case cellSeparator
    case tableSectionHeaderBackground
    case dimmingView
}

public extension SemanticCustomColor {
    
    var uiColor: UIColor {
        let bundle = Bundle(for: BaseTableViewController.self)
        guard let color = UIColor(named: "\(self.rawValue)Color", in: bundle, compatibleWith: nil) else {
            return UIColor.black
        }
        return color
    }
    
    var cgColor: CGColor {
        let bundle = Bundle(for: BaseTableViewController.self)
        guard let color = UIColor(named: "\(self.rawValue)Color", in: bundle, compatibleWith: nil) else {
            return UIColor.black.cgColor
        }
        return color.cgColor
    }

}
