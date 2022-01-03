//
//  AnalyticsTracking.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 8/5/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

protocol AnalyticsTracking {
    func logAnalytics(event: AnalyticsEventConstants.EventName, parameters: [String: Any]?)
    func logAnalytics(screen: AnalyticsViewConstants.ViewName)
    func logAnalytics(userID: String)
}

private enum AnalyticsType: String {
    case userEvent
    case screenView
}

private enum Attribute: String {
    case userId
}

extension AnalyticsTracking {
    
    func logAnalytics(event: AnalyticsEventConstants.EventName, parameters: [String: Any]? = nil) {
        NewRelic.recordCustomEvent(AnalyticsType.userEvent.rawValue, name: event.rawValue, attributes: parameters)
    }
    
    func logAnalytics(screen: AnalyticsViewConstants.ViewName) {
        NewRelic.recordCustomEvent(AnalyticsType.screenView.rawValue, name: screen.rawValue, attributes: nil)
    }
    
    func logAnalytics(userID: String) {
        NewRelic.setAttribute(Attribute.userId.rawValue, value: userID)
    }
    
    func logAnalyticsSignout() {
        NewRelic.removeAttribute(Attribute.userId.rawValue)
    }
    
}

struct AnalyticsEventConstants {
    
    enum EventName: String {
        case interactiveLogIn = "interactive_log_in"
        case loadGrowersList = "load_growers_list"
        case addNewGrower = "add_new_grower"
        case saveGrower = "save_grower"
        case editGrower = "edit_grower"
        case deleteGrower = "delete_grower"
        case serverConnectionError = "server_connection_error"
        case createNewPlan = "create_new_plan"
        case viewExistingPlan = "view_existing_plan"
        case viewExistingPlanReadOnly = "view_existing_plan_read_only"
        case savePlan = "save_plan"
        case deletePlan = "delete_plan"
        case sharePDFEstimate = "share_pdf_estimate"
        case sharePDFCropPlan = "share_pdf_crop_plan"
        case createNewApplication = "create_new_application"
        case createNewSeedApplication = "create_new_seed_application"
        case viewExistingApplication = "view_existing_application"
        case viewExistingSeedApplication = "view_existing_seed_application"
        case saveApplication = "save_application"
        case saveSeedApplication = "save_seed_application"
        case deleteApplication = "delete_application"
        case deleteSeedApplication = "delete_seed_application"
        case cancelApplication = "cancel_application"
        case cancelSeedApplication = "cancel_seed_application"
        case useSameRateToggle = "use_same_rate_toggle"
        case applicationTargetCropSelected = "application_target_crop_selected"
        case seedApplicationTargetCropSelected = "seed_application_target_crop_selected"
        case syncProductsAndCrops = "sync_products_and_crops"
        case signOut = "sign_out"
        case sendFeedbackEmail = "send_feedback_email"
    }
    
}

struct AnalyticsViewConstants {
    
    enum ViewName: String {
        case logIn = "LoginViewController"
        case growersList = "GrowersListViewController"
        case growerDetails = "GrowerDetailsViewController"
        case growerProfile = "GrowerProfileViewController"
        case cropsList = "CropsListViewController"
        case zonesList = "ZonesListViewController"
        case productsList = "ProductsListViewController"
        case seedsList = "SeedsListViewController"
        case planDetails = "PlanDetailsViewController"
        case applicationDetails = "ApplicationDetailsViewController"
        case settings = "SettingsViewController"
        case quantityModal = "QuantityModal"
        case rateModal = "RateModal"
    }
    
}
