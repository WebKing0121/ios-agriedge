//
//  SettingsViewController.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 7/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: BaseTableViewController, AnalyticsTracking {
    
    // MARK: Properties

    private var numberOfToggleRows: Int {
        return (hasDisabledAllIndividualOptions || RebateAttribute.allValues.isEnabled == false) ? 1 : RebateAttribute.allCases.count
    }
    
    private var hasDisabledAllIndividualOptions: Bool {
        return RebateAttribute.allCases.filter({ $0 != .allValues && $0.isEnabled }).isEmpty
    }
    
    private lazy var toggleSettingsHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "Cost-Share Calculation"
        return headerView
    }()
    
    private lazy var syncSettingsHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "Sync"
        return headerView
    }()

    private lazy var generalSettingsHeaderView: TableSectionHeaderView = {
        let headerView = TableSectionHeaderView.fromNib
        headerView.titleLabelText = "General"
        return headerView
    }()
    
    private lazy var downloadStaticDataButtonCell: StyledButtonTableViewCell = {
        let cell = StyledButtonTableViewCell.fromNib
        cell.buttonTitleLabelText = "Sync Products and Crops"
        cell.buttonType = (.tertiary, .teal)
        cell.delegate = self
        return cell
    }()
        
    private lazy var sendFeedbackEmailCell: StyledButtonTableViewCell = {
        let cell = StyledButtonTableViewCell.fromNib
        cell.buttonTitleLabelText = "Send Feedback"
        cell.buttonType = (.tertiary, .teal)
        cell.delegate = self
        return cell
    }()
    
    private lazy var signOutButtonCell: StyledButtonTableViewCell = {
        let cell = StyledButtonTableViewCell.fromNib
        cell.buttonTitleLabelText = "Sign Out"
        cell.buttonType = (style: .tertiary, color: .red)
        cell.delegate = self
        return cell
    }()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalytics(screen: .settings)
        tableView.register(LabeledToggleTableViewCell.nib, forCellReuseIdentifier: LabeledToggleTableViewCell.nibName)
    }
    
    // MARK: Button Actions
    
    private func downloadStaticData() {
        guard ReachabilityManager.shared.isNetworkReachable else {
            showNoConnectionAlert()
            return
        }

        syncSettingsHeaderView.titleLabelText = "Updating Products and Crops Data..."
        
        logAnalytics(event: .syncProductsAndCrops)
        
        let userID = PersistenceLayer().fetch(UserObject.self)?.first?.userID ?? ""
        OktaSessionManager.shared.refreshTokensIfNeeded {
            StaticDataLayer().fetchStaticData(StaticDataEndpoint.fetchStaticData(userID: userID)) {
                (result: (StaticDataServiceResult<String>)) in
                
                switch result {
                case .success:
                    self.showAlert(title: "Success", message: "Updated Products and Crops Data")
                    log(info: "downloaded static data")
                case .successWithErrors:
                    self.showAlert(title: "Success with errors", message: "Updated Products and Crops Data. Some errors were encountered.")
                    log(info: "downloaded static data but encountered some errors")
                case .failure(let error):
                    self.showAlert(title: "Error", message: "Error Updating Products and Crops Data")
                    log(error: "error downloading static data: \(error)")
                }
                
                self.syncSettingsHeaderView.titleLabelText = "Sync"
            }
        }
    }
    
    private func signOut() {
        let logOutAction = UIAlertAction(title: "Log Out", style: .default) { _ in
            OktaSessionManager.shared.signOut()
            UserDefaults.setIsLoggedIn(value: false)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "UnwindToLogin", sender: self)
                DualPersistenceLayer().emptyRealm()
                DualPersistenceLayer(configuration: .update).emptyRealm()
                
                self.logAnalytics(event: .signOut)
                self.logAnalyticsSignout()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        self.showChoiceAlert(title: "Are you sure you want to log out?", message: nil, alertActions: [logOutAction, cancelAction])
    }
    
    private func sendFeedback() {
        logAnalytics(event: .sendFeedbackEmail)
        
        let recipient = "act@agconnections.com"
        let subject = "[AgriEdge Calculator Tool Feedback]"
        
        if let outlookEmailUrl = createOutlookEmailUrl(to: recipient, subject: subject) {
            UIApplication.shared.open(outlookEmailUrl)
        } else if MFMailComposeViewController.canSendMail() {
            let email = MFMailComposeViewController()
            email.mailComposeDelegate = self
            email.setToRecipients([recipient])
            email.setSubject(subject)
            present(email, animated: true)
        } else {
            showAlert(title: "Can't send email", message: "Please check your email settings and try again.")
        }
    }
    
    private func createOutlookEmailUrl(to: String, subject: String) -> URL? {
        if let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)"),
            UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else {
            return nil
        }
    }
    
}

// MARK: - TableView Delegate & Data Source

extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TableSection.toggles.rawValue:
            return numberOfToggleRows
        case TableSection.sync.rawValue:
            return 1
        case TableSection.general.rawValue:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case TableSection.toggles.rawValue:
            return toggleSettingsHeaderView
        case TableSection.sync.rawValue:
            return syncSettingsHeaderView
        case TableSection.general.rawValue:
            return generalSettingsHeaderView
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case TableSection.toggles.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LabeledToggleTableViewCell.nibName, for: indexPath) as? LabeledToggleTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.titleLabelText = RebateAttribute.allCases.map({ $0.genericTitle })[indexPath.row]
            cell.isToggleOn = RebateAttribute.allCases.map({ $0.isEnabled })[indexPath.row]
            cell.titleLabelColor = SemanticCustomColor.primaryInk.uiColor
            if indexPath.row == 0 {
                cell.isCellSeparatorHidden = true
                cell.titleLabelFont = .systemFont(ofSize: 17)
                cell.titleLabelLeadingConstraintConstant = 16
            } else {
                cell.titleLabelFont = .systemFont(ofSize: 15)
                cell.titleLabelLeadingConstraintConstant = 58
                cell.isCellSeparatorHidden = indexPath.isLastOf(RebateAttribute.allCases)
            }
            return cell
        case TableSection.sync.rawValue:
            return downloadStaticDataButtonCell
        case TableSection.general.rawValue:
            if indexPath.row == 0 {
                return sendFeedbackEmailCell
            } else {
                return signOutButtonCell
            }
        default:
            return UITableViewCell()
        }
    }
    
    enum TableSection: Int {
        case toggles
        case sync
        case general
    }
    
}

// MARK: - LabeledToggleTableViewCellDelegate

extension SettingsViewController: LabeledToggleTableViewCellDelegate {
    
    func didToggleSwitch(_ labeledToggleTableViewCell: LabeledToggleTableViewCell, sender: UISwitch) {
        guard let indexPath = tableView.indexPath(for: labeledToggleTableViewCell) else { return }
        
        UserDefaults.standard.set(sender.isOn, forKey: "\(RebateAttribute.allCases[indexPath.row].rawValue)")
        
        if indexPath.row == 0 || hasDisabledAllIndividualOptions {
            var indexes = RebateAttribute.allCases.map({ $0.indexPath })
            indexes.removeFirst()
            
            tableView.beginUpdates()
            
            if sender.isOn {
                if indexPath.row == 0 {
                    RebateAttribute.allCases.forEach({ UserDefaults.standard.set(sender.isOn, forKey: "\($0.rawValue)" )})
                }
                tableView.insertRows(at: indexes, with: .fade)
            } else {
                tableView.deleteRows(at: indexes, with: .fade)
            }
            
            if !sender.isOn && hasDisabledAllIndividualOptions {
                let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LabeledToggleTableViewCell
                cell?.isToggleOn = false
                UserDefaults.standard.set(sender.isOn, forKey: "\(RebateAttribute.allValues.rawValue)")
            }
            
            tableView.endUpdates()
        }
    }
    
}

// MARK: - BorderedButtonTableViewCellDelegate

extension SettingsViewController: StyledButtonTableViewCellDelegate {

    func didTapButton(_ borderedButtonTableViewCell: StyledButtonTableViewCell, sender: StyledButton) {
        if borderedButtonTableViewCell == signOutButtonCell {
            signOut()
        } else if borderedButtonTableViewCell == sendFeedbackEmailCell {
            sendFeedback()
        } else if borderedButtonTableViewCell == downloadStaticDataButtonCell {
            downloadStaticData()
        }
    }
    
}

// MARK: - MFMailComposeViewControllerDelegate

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
