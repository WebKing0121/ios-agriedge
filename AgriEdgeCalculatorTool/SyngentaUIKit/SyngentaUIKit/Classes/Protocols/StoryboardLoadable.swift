//
//  StoryboardLoadable.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 11/18/19.
//

import UIKit

public protocol StoryboardLoadable: AnyObject {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle { get }
}

public extension StoryboardLoadable {
    
    static var storyboardName: String {
        return String(describing: self.self)
    }
    
    static var storyboardBundle: Bundle {
        return Bundle(for: self.self)
    }
    
    static var storyboard: UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: storyboardBundle)
    }
    
}

public extension StoryboardLoadable where Self: UIViewController {

    static func fromStoryboard(named customStoryboardName: String? = nil, in bundle: Bundle? = nil) -> Self {
        let storyboard = UIStoryboard(name: customStoryboardName ?? storyboardName, bundle: bundle ?? storyboardBundle)
        return storyboard.instantiateViewController(withIdentifier: storyboardName) as! Self // swiftlint:disable:this force_cast
    }

    static var fromStoryboard: Self {
        return storyboard.instantiateViewController(withIdentifier: storyboardName) as! Self // swiftlint:disable:this force_cast
    }

}
