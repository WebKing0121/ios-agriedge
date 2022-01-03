//
//  ReachabilityManager.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/23/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Reachability

class ReachabilityManager {
    
    static let shared = ReachabilityManager()
    
    var listeners = [ReachabilityObserving]()
    
    private init() { }
    
    private let reachability = Reachability()!
    
    func startNotifier() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            log(error: "could not start reachability notifier")
        }
    }
    
    func stopNotifier() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    func addListener(listener: ReachabilityObserving) {
        listeners.append(listener)
    }
    
    func removeListener(listener: ReachabilityObserving) {
        listeners = listeners.filter { $0 !== listener }
    }
    
    var isNetworkReachable: Bool {
        return reachability.connection != .none
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
        
        for listener in listeners {
            listener.reachabilityChanged(status: reachability.connection)
        }

    }
    
}

protocol ReachabilityObserving: AnyObject {
    func observeReachability()
    func stopObservingReachability()
    func reachabilityChanged(status: Reachability.Connection)
}

extension ReachabilityObserving where Self: UIViewController {
    
    func observeReachability() {
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    func stopObservingReachability() {
        ReachabilityManager.shared.removeListener(listener: self)
    }

}
