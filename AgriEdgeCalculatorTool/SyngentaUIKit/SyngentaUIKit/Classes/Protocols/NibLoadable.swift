//
//  NibLoadable.swift
//  SyngentaUIKit
//
//  Created by lloyd on 6/12/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public protocol NibLoadable: AnyObject {
    static var nibName: String { get }
    static var nibBundle: Bundle { get }
}

public extension NibLoadable {
    
    static var nibName: String {
        return String(describing: self.self)
    }
    
    static var nibBundle: Bundle {
        return Bundle(for: self.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nibBundle)
    }
    
}

public extension NibLoadable where Self: UIView {
    //swiftlint:disable force_cast
    static var fromNib: Self {
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
    
    static func register(on tableView: UITableView) {
        tableView.register(nib, forCellReuseIdentifier: nibName)
    }
    
}

public extension NibLoadable where Self: UITableViewCell {

    static func dequeue(for tableView: UITableView, at indexPath: IndexPath) -> Self {
        return tableView.dequeueReusableCell(withIdentifier: nibName, for: indexPath) as! Self
    }
    
}
