//
//  LoginViewController.swift
//  AgriEdgeCalculatorTool
//
//  Created by Stephen Gray on 5/8/20.
//  Copyright © 2020 Syngenta. All rights reserved.
//

import UIKit

class OktaLoginViewController: UIViewController, AlertPresenting, AnalyticsTracking {
    
    // MARK: Outlets
    
    @IBOutlet private weak var logInButton: StyledButton!
    @IBOutlet private weak var activityIndicatorView: UIStackView!
    
    // MARK: Properties
        
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.configure(buttonStyle: .primary, buttonColor: .teal)
        logAnalytics(screen: .logIn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkForAuthSession()
    }
    
    // MARK: Okta Login
    
    // check if there is a user logged in
    private func checkForAuthSession() {
        guard UserDefaults.isLoggedIn else { return }
        
        if OktaSessionManager.shared.hasAuthSession {
            OktaSessionManager.shared.refreshTokensIfNeeded(inViewController: self) {
                self.naviagteToGrowersList()
            }
        }
    }
    
    // user tapped "Log In with SSO" button
    @IBAction private func interactiveLogIn(_ sender: UIButton) {
        logAnalytics(event: .interactiveLogIn)
        
        guard ReachabilityManager.shared.isNetworkReachable else {
            showNoConnectionAlert()
            return
        }
        
        self.activityIndicatorView.fadeIn()
        
        ServiceLayer().fetch(LoginEndpoint.healthcheck) {
            (result: (ServiceResult<HealthcheckStatus>)) in
            
            self.activityIndicatorView.fadeOut()
            
            switch result {
            case .success(let healthcheck):
                log(info: "downloaded \(healthcheck) healthcheck")
                guard healthcheck.isAPIHealthy else {
                    self.logAnalytics(event: .serverConnectionError)
                    self.showAlert(title: AlertConstants.connectionErrorTitle,
                                   message: AlertConstants.serverErrorMessage)
                    return
                }
                
                self.signInWithBrowser()
            case .failure(let error):
                log(error: "error downloading results: \(error)")
                self.logAnalytics(event: .serverConnectionError)
                self.showAlert(title: AlertConstants.connectionErrorTitle,
                               message: AlertConstants.serverErrorMessage)
            }
        }
    }
    
    private func signInWithBrowser() {
        OktaSessionManager.shared.signInWithBrowser(from: self) { result in
            
            self.activityIndicatorView.fadeIn()
            
            switch result {
            case .success:
                OktaSessionManager.shared.getUser(completion: { userData in
                    switch userData {
                    case .success(let data):
                        guard let email = data["preferred_username"] as? String,
                            let lastName = data["family_name"] as? String,
                            let firstName = data["given_name"] as? String else {
                                log(error: "Incomplete Data in Okta Session Manager Request")
                                return
                        }
                        
                        ServiceLayer().fetch(LoginEndpoint.login(userEmail: email)) {
                            (result: (ServiceResult<UserID>)) in
                            
                            switch result {
                            case .success(let userID):
                                let userObject = UserObject().project(from: User(userID: userID.userID, firstName: firstName, lastName: lastName, email: email, allowedZones: [String](), specialists: [Specialist]()))
                                PersistenceLayer().create(userObject)
                                
                                self.fetchGrowers()
                                self.fetchStaticData()
                                self.logAnalytics(userID: userID.userID)
                                
                                // successfully logged in; user and session token cached, session content and userID downloaded
                                UserDefaults.setIsLoggedIn(value: true)
                            case .failure(let error):
                                self.showLogInAlert()
                                log(error: "error downloading userID: \(error)")
                                self.activityIndicatorView.fadeOut()
                                return
                            }
                        }
                        
                    case .failure(let error):
                        self.showLogInAlert()
                        log(error: "error requesting session content: \(error)")
                        self.activityIndicatorView.fadeOut()
                        return
                    }
                })
            case .failure(let error):
                self.showLogInAlert()
                self.activityIndicatorView.fadeOut()
                log(error: "error logging user in: \(error)")
                return
            }
        }
    }
    
    // MARK: Navigation
    
    private func naviagteToGrowersList() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showGrowersListSegue", sender: self)
            self.logInButton.fadeIn()
            self.activityIndicatorView.fadeOut()
        }
    }
    
    @IBAction private func unwindToLoginViewController(_ segue: UIStoryboardSegue) {}
    
    // MARK: Download Growers and Static Data
    
    private func fetchGrowers() {
        let userID = PersistenceLayer().fetch(UserObject.self)?.first?.userID ?? ""
        OktaSessionManager.shared.refreshTokensIfNeeded {
            ServiceLayer().fetch(GrowersEndpoint.fetchGrowers(userID: userID, persistCompletion: {
                // TODO: remove this gross hack when we build out the real log in flow
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.naviagteToGrowersList()
                }
            }), cleanPersist: false) { (result: (ServiceResult<[Grower]>)) in
                switch result {
                case .success(let growers):
                    log(info: "downloaded \(growers.count) growers")
                case .failure(let error):
                    log(error: "error downloading growers: \(error)")
                    self.downloadError("Error Downloading Growers")
                }
            }
        }
    }
    
    private func fetchStaticData() {
        let userID = PersistenceLayer().fetch(UserObject.self)?.first?.userID ?? ""
        OktaSessionManager.shared.refreshTokensIfNeeded {
            StaticDataLayer().fetchStaticData(StaticDataEndpoint.fetchStaticData(userID: userID)) {
                (result: (StaticDataServiceResult<String>)) in
                
                switch result {
                case .success:
                    log(info: "downloaded StaticData without errors")
                case .successWithErrors:
                    log(info: "downloaded StaticData but encountered some errors")
                case .failure(let error):
                    log(error: "error downloading results: \(error)")
                }
            }
        }
    }
    
    // MARK: Error Alerts
    
    private func showLogInAlert() {
        showAlert(title: "Log In Error", message: "We encountered an error logging in. Please check your credentials and try again", completion: nil)
    }
    
    private func downloadError(_ title: String) {
        DispatchQueue.main.async {
            self.activityIndicatorView.fadeOut()
            
            let tryAgainAction = UIAlertAction(title: "Try Again", style: .default) { _ in
                self.fetchGrowers()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            self.showChoiceAlert(title: title, message: nil, alertActions: [tryAgainAction, cancelAction])
        }
        
    }
    
}

// MARK: - UserDefaults isLoggedIn

extension UserDefaults {
    
    class var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    class func setIsLoggedIn(value: Bool) {
        UserDefaults.standard.set(value, forKey: "isLoggedIn")
    }
    
}
