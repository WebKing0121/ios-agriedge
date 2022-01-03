//
//  OktaSessionManager.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 5/8/20.
//  Copyright © 2020 Syngenta. All rights reserved.
//

import OktaOidc

class OktaSessionManager {
    
    // MARK: - Singleton pattern
    
    static let shared = OktaSessionManager()
    public var hasAuthSession: Bool {
        return oktaStateManager != nil
    }
    public var accessToken: String {
        return oktaStateManager?.accessToken ?? "no auth token present"
    }
    
    // MARK: - Public methods
    
    public func signInWithBrowser(from viewController: UIViewController,
                                  completion: @escaping (OktaSessionManagerResult<Error>) -> Void) {
        oktaOidc?.signInWithBrowser(from: viewController) { oktaStateManager, error in
            if let error = error {
                self.oktaStateManager = nil
                log(error: "error in signInWithBrowser \(error)")
                completion(.failure(error))
                return
            }
            
            self.oktaStateManager = oktaStateManager
            completion(.success)
        }
    }
    
    public func getUser(completion: @escaping (OktaSessionManagerObjectResult<[String: Any], String>) -> Void) {
        oktaStateManager?.getUser { response, error in
            if let error = error {
                completion(.failure(error.localizedDescription))
                return
            }
            
            completion(.success(response ?? [:]))
        }
    }
    
    func refreshTokensIfNeeded(inViewController viewController: UIViewController? = nil, completion: @escaping () -> Void = {}) {
        if oktaStateManager?.accessToken != nil {
            // we already have a valid accessToken
            completion()
        } else {
            // we need to refresh the token first
            oktaStateManager?.renew { oktaStateManager, error in
                if let error = error {
                    log(error: "error in oktaStateManager.renew: \(error)")
                    if let viewController = viewController {
                        self.signInWithBrowser(from: viewController) { result in
                            switch result {
                            case .success:
                                log(info: "Successfully signInWithBrowser")
                            case .failure(let error):
                                log(error: "Failed signInWithBrowser: \(error)")
                            }
                            completion() // completion must be called in all logic paths
                        }
                    } else {
                        completion()
                    }
                    return
                }
                
                self.oktaStateManager = oktaStateManager
                completion()
                log(info: "token refreshed")
            }
        }
    }
    
    public func signOut() {
        oktaStateManager?.clear()
    }
    
    // MARK: - Private properties
    
    private var oktaOidc: OktaOidc?
    private var oktaStateManager: OktaOidcStateManager? {
        didSet {
            oldValue?.clear()
            oktaStateManager?.writeToSecureStorage()
        }
    }
    
    // MARK: - Private methods
    
    private init() {
        initializeOkta()
    }
    
    private func initializeOkta() {
        oktaOidc = try? OktaOidc()
        if let config = oktaOidc?.configuration {
            oktaStateManager = OktaOidcStateManager.readFromSecureStorage(for: config)
        }
    }
}

// MARK: - Result types

enum OktaSessionManagerResult<Failure> {
    case success
    case failure(Failure)
}

enum OktaSessionManagerObjectResult<Success, Failure> {
    case success(Success)
    case failure(Failure)
}
