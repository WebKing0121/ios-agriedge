//
//  TabbedContainerViewController.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 11/13/19.
//

import UIKit

public class TabbedContainerViewController: UIViewController, StoryboardLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var viewControllerContainerView: UIView!
    @IBOutlet private weak var tabContainerStackView: UIStackView!
    @IBOutlet private weak var tabContainerView: UIView!
    @IBOutlet private weak var tabIndicatorView: UIView!
    
    // autolayout constraints
    @IBOutlet private weak var tabIndicatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tabIndicatorWidthConstraint: NSLayoutConstraint!
    private var currentViewControllerLeadingConstraint: NSLayoutConstraint?
    private var currentViewControllerTrailingConstraint: NSLayoutConstraint?
    
    // MARK: Public Properties
    
    public weak var delegate: TabbedContainerViewControllerPresenting?
    
    // MARK: Private Properties
        
    private var tabs = [TabbedContainerTabView]()
    private var viewControllers = [UIViewController]()
    private var currentViewController: UIViewController?
    private var newViewController: UIViewController?
    private var currentTabIndex = 0
    private var isNavigating: Bool = false
    private let animationDuration = 0.2
    
    // MARK: View Life Cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    // MARK: Configure

    private func configureViews() {
        guard let items = delegate?.tabbedContainerViewControllerContent(for: self) else { return }
        
        // populate the list of view controllers
        viewControllers = items.map({ $0.viewController })

        // populate the list of tabs
        tabs = items.map({ $0.tabTitle }).enumerated().map({
            (index: Int, tabTitle: String) -> TabbedContainerTabView in
            
            let tab = TabbedContainerTabView.fromNib
            tab.configure(tabTitle: tabTitle)
            tab.delegate = self
            tab.tag = index
            return tab
        })
        tabs.forEach({ tabContainerStackView.addArrangedSubview($0) })
        
        // indicator view width is determined by the container's width and the number of tabs
        tabIndicatorWidthConstraint.constant = viewControllerContainerView.frame.size.width / CGFloat(tabs.count)
        tabIndicatorView.layoutIfNeeded()
        
        // set first view controller as the default when the view loads
        currentViewController = viewControllers.first
        guard let currentViewController = currentViewController,
            let currentViewControllerView = currentViewController.view else { return }
        addChild(currentViewController)
        viewControllerContainerView.addSubview(currentViewControllerView)
        currentViewControllerView.translatesAutoresizingMaskIntoConstraints = false
        currentViewControllerView.topAnchor.constraint(equalTo: viewControllerContainerView.topAnchor).isActive = true
        currentViewControllerView.bottomAnchor.constraint(equalTo: viewControllerContainerView.bottomAnchor).isActive = true
        
        // create leading and trailing constraints for the current view conroller's starting position
        currentViewControllerLeadingConstraint = NSLayoutConstraint(item: currentViewControllerView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: viewControllerContainerView,
                                                   attribute: .leading,
                                                   multiplier: 1.0,
                                                   constant: 0)
        currentViewControllerTrailingConstraint = NSLayoutConstraint(item: currentViewControllerView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: viewControllerContainerView,
                                                    attribute: .trailing,
                                                    multiplier: 1.0,
                                                    constant: 0)
        // layout the starting position constraints
        currentViewControllerLeadingConstraint?.isActive = true
        currentViewControllerTrailingConstraint?.isActive = true
    }
    
    // MARK: Tab Navigation
    
    private func navigateToTabIndex(_ selectedTabIndex: Int) {
        // only attempt to navigate if we're not already navigating
        // and a tab is selected that we're not currently on
        guard !isNavigating,
            currentTabIndex != selectedTabIndex else { return }
        
        isNavigating = true
        
        // update UI state for the selected tab
        tabs[currentTabIndex].isSelected = false
        tabs[selectedTabIndex].isSelected = true
        tabIndicatorLeadingConstraint.constant = tabContainerStackView.arrangedSubviews[selectedTabIndex].frame.minX
        UIView.animate(withDuration: animationDuration, animations: {
            self.tabContainerView.layoutIfNeeded()
        })
        
        // add the new view controller selected to the container view
        currentViewController?.willMove(toParent: nil)
        newViewController = viewControllers[selectedTabIndex]
        guard let newViewController = newViewController,
            let newViewControllerView = newViewController.view else { return }
        addChild(newViewController)
        viewControllerContainerView.addSubview(newViewControllerView)
        
        // pin the top and bottom anchors of the new view controller to the container view
        newViewControllerView.translatesAutoresizingMaskIntoConstraints = false
        newViewControllerView.topAnchor.constraint(equalTo: viewControllerContainerView.topAnchor).isActive = true
        newViewControllerView.bottomAnchor.constraint(equalTo: viewControllerContainerView.bottomAnchor).isActive = true

        // determine the starting position for the new view controller
        // based on if the new tab selected is to the right or left of the current tab
        var leadingTrailingConstraintConstant: CGFloat = 0
        let containerWidth = viewControllerContainerView.frame.size.width
        if currentTabIndex < selectedTabIndex { // moving to the right
            leadingTrailingConstraintConstant = containerWidth
        } else if currentTabIndex > selectedTabIndex { // moving to the left
            leadingTrailingConstraintConstant = -containerWidth
        }

        // create leading and trailing constraints for the starting position
        let leadingConstraint = NSLayoutConstraint(item: newViewControllerView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: viewControllerContainerView,
                                                   attribute: .leading,
                                                   multiplier: 1.0,
                                                   constant: leadingTrailingConstraintConstant)
        let trailingConstraint = NSLayoutConstraint(item: newViewControllerView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: viewControllerContainerView,
                                                    attribute: .trailing,
                                                    multiplier: 1.0,
                                                    constant: leadingTrailingConstraintConstant)
        
        // layout the starting position constraints
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
        viewControllerContainerView.layoutIfNeeded()

        // animate the new view controller to its ending position.
        // set leading and trailing constraints to 0 so the new view controller
        // is pinned on all sides to the container view
        UIView.transition(with: viewControllerContainerView, duration: animationDuration, options: .curveLinear, animations: {
            leadingConstraint.constant = 0
            trailingConstraint.constant = 0
            self.currentViewControllerLeadingConstraint?.constant = -leadingTrailingConstraintConstant
            self.currentViewControllerTrailingConstraint?.constant = -leadingTrailingConstraintConstant

            self.viewControllerContainerView.layoutIfNeeded()
        }, completion: { _ in
            // remove the current view controller from the parent and superview
            // set the current view controller as the new view controller
            // since the animation has completed
            self.currentViewController?.removeFromParent()
            self.currentViewController?.view.removeFromSuperview()
            self.currentViewController = newViewController
            self.currentViewControllerLeadingConstraint = leadingConstraint
            self.currentViewControllerTrailingConstraint = trailingConstraint
            self.newViewController = nil
            self.currentTabIndex = selectedTabIndex
            self.isNavigating = false
            newViewController.didMove(toParent: self)
        })
    }
    
}

// MARK: - TabbedContainerTabViewDelegate

extension TabbedContainerViewController: TabbedContainerTabViewDelegate {
    
    public func didSelectTab(_ sender: TabbedContainerTabView) {
        navigateToTabIndex(sender.tag)
    }

}

// MARK: - TabbedContainerViewControllerNavigating

extension TabbedContainerViewController: TabbedContainerViewControllerNavigating {
    
    public func tabbedContainerDidSelectNextController() {
        guard currentTabIndex + 1 < tabs.count else { return }
        navigateToTabIndex(currentTabIndex + 1)
    }
    
    public func tabbedContainerDidSelectPreviousController() {
        guard currentTabIndex - 1 >= 0 else { return }
        navigateToTabIndex(currentTabIndex - 1)
    }
    
}
