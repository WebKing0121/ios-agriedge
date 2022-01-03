//
//  BaseTableViewController.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 6/14/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import Foundation
import UIKit

open class BaseTableViewController: UIViewController, AlertPresenting {
    
    // MARK: Public Properties
    
    open var tableView = UITableView(frame: .zero, style: .grouped)
    
    open var primaryButton: (title: String, action: (() -> Void))? { return nil }
    
    public var isPrimaryButtonEnabled: Bool {
        get {
            return styledButton?.isEnabled ?? false
        }
        set {
            styledButton?.isEnabled = newValue
        }
    }
    
    public var isPrimaryButtonHidden: Bool {
        get {
            return styledButtonView?.isHidden ?? true
        }
        set {
            styledButtonView?.isHidden = newValue

            if newValue {
                tableViewBottomConstraint?.constant = 0
            } else {
                tableViewBottomConstraint?.constant = -BaseTableViewConstants.styledButtonViewHeight
            }
        }
    }
    
    public var primaryButtonViewBottomConstraintConstant: CGFloat? {
        didSet {
            if primaryButton == nil {
                primaryButtonViewBottomConstraintConstant = nil
                return
            }
            styledButtonViewBottomConstraint?.constant = primaryButtonViewBottomConstraintConstant ?? 0.0
            tableViewBottomConstraint?.constant = (primaryButtonViewBottomConstraintConstant ?? 0.0) - BaseTableViewConstants.styledButtonViewHeight
        }
    }
    
    // MARK: Private Properties
    
    private var styledButton: StyledButton?
    private var styledButtonView: UIView?
    
    private var tableViewBottomConstraint: NSLayoutConstraint?
    private var styledButtonViewBottomConstraint: NSLayoutConstraint?

    // MARK: View Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = SemanticCustomColor.tableBackground.uiColor

        configureTableView()
        registerForKeyboardNotifications()
        
        if let primaryButton = primaryButton {
            configurePrimaryButtonView(title: primaryButton.title)
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
        super.viewWillDisappear(animated)
    }
    
    // MARK: Configure
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: BaseTableViewConstants.topConentInset, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = SemanticCustomColor.tableBackground.uiColor
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        if primaryButton == nil {
            tableViewBottomConstraint?.constant = primaryButtonViewBottomConstraintConstant ?? 0
            tableViewBottomConstraint?.isActive = true
        } else {
            if let primaryButtonViewBottomConstraintConstant = primaryButtonViewBottomConstraintConstant {
                 tableViewBottomConstraint?.constant = primaryButtonViewBottomConstraintConstant - BaseTableViewConstants.styledButtonViewHeight
            } else {
                tableViewBottomConstraint?.constant = -BaseTableViewConstants.styledButtonViewHeight
            }

            tableViewBottomConstraint?.isActive = true
        }
    }
    
    private func configurePrimaryButtonView(title: String) {
        styledButtonView = UIView(frame: .zero)
        guard let styledButtonView = styledButtonView else { return }
        
        view.addSubview(styledButtonView)
        
        styledButtonView.backgroundColor = SemanticCustomColor.tableBackground.uiColor
        styledButtonView.translatesAutoresizingMaskIntoConstraints = false
        styledButtonView.heightAnchor.constraint(equalToConstant: BaseTableViewConstants.styledButtonViewHeight).isActive = true
        styledButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        styledButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        styledButtonViewBottomConstraint = styledButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        styledButtonViewBottomConstraint?.constant = primaryButtonViewBottomConstraintConstant ?? 0
        styledButtonViewBottomConstraint?.isActive = true
        
        styledButton = StyledButton()
        guard let styledButton = styledButton else { return }
        styledButton.configure(buttonStyle: .primary, buttonColor: .teal)
        styledButton.setTitle(title, for: . normal)
        styledButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        styledButtonView.addSubview(styledButton)
        
        styledButton.translatesAutoresizingMaskIntoConstraints = false
        styledButton.heightAnchor.constraint(equalToConstant: BaseTableViewConstants.styledButtonHeight).isActive = true
        styledButton.centerYAnchor.constraint(equalTo: styledButtonView.centerYAnchor).isActive = true
        styledButton.leadingAnchor.constraint(equalTo: styledButtonView.leadingAnchor, constant: 16).isActive = true
        styledButton.trailingAnchor.constraint(equalTo: styledButtonView.trailingAnchor, constant: -16).isActive = true
    }
    
    @objc private func primaryButtonTapped() {
        primaryButton?.action()
    }
    
    // MARK: Keyboard Notifications

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustViewForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc open func adjustViewForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey]) as? UInt else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = UIEdgeInsets(top: BaseTableViewConstants.topConentInset, left: 0, bottom: 0, right: 0)
            
            if primaryButton != nil {
                styledButtonViewBottomConstraint?.constant = primaryButtonViewBottomConstraintConstant ?? 0
            }
            
        } else {
            if primaryButton != nil {
                styledButtonViewBottomConstraint?.constant = -keyboardScreenEndFrame.height + view.safeAreaInsets.bottom
                tableView.contentInset = UIEdgeInsets(top: BaseTableViewConstants.topConentInset,
                                                      left: 0,
                                                      bottom: keyboardViewEndFrame.height + (primaryButtonViewBottomConstraintConstant ?? 0),
                                                      right: 0)
            } else {
                tableView.contentInset = UIEdgeInsets(top: BaseTableViewConstants.topConentInset,
                                                      left: 0,
                                                      bottom: keyboardViewEndFrame.height - BaseTableViewConstants.footerHeight + (primaryButtonViewBottomConstraintConstant ?? 0),
                                                      right: 0)
            }
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset

        if primaryButton != nil {
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension BaseTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return BaseTableViewConstants.headerHeight
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return BaseTableViewConstants.footerHeight
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return TableSectionFooterView.fromNib
    }
    
}

// MARK: Constants

public struct BaseTableViewConstants {
    public static let topConentInset: CGFloat = 16
    public static let headerHeight: CGFloat = 64
    public static let footerHeight: CGFloat = 24
    public static let styledButtonViewHeight: CGFloat = 68
    public static let styledButtonHeight: CGFloat = 40
}
