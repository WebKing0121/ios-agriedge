//
//  ToggleButtonContainerTableViewCell.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/10/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class ToggleButtonContainerTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    public weak var delegate: ToggleButtonContainerTableViewCellDelegate?
    
    private var buttonTitles = [String]()
    private var toggleButtons = [ToggleButton]()
    private var knownViewWidth: CGFloat = 0
    private var knownHeight: CGFloat = 0
    private var toggleType: ToggleType = .checkmark

    // MARK: Init
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configure
    
    public func configureForHeight(with titles: [String], viewWidth: CGFloat) -> CGFloat {
        guard knownViewWidth != viewWidth else {
            return knownHeight
        }
        
        knownViewWidth = viewWidth
        
        var nextX: CGFloat = 20
        var nextY: CGFloat = 8
        toggleButtons.forEach({ $0.removeFromSuperview() })
        
        toggleButtons = titles.enumerated().map({
            (index: Int, title: String) -> ToggleButton in
            buttonTitles.append(title)
            let titleText = title
            let width = titleText.width(withConstrainedHeight: 32, font: .systemFont(ofSize: 17)) + 48
            let needsNewRow = (viewWidth - 20) < (nextX + width)
            var button: ToggleButton
            
            if needsNewRow {
                nextY += 40
                nextX = 20
                button = ToggleButton(frame: CGRect(x: nextX, y: nextY, width: width, height: 32), toggleType: toggleType)
            } else {
                button = ToggleButton(frame: CGRect(x: nextX, y: nextY, width: width, height: 32), toggleType: toggleType)
            }

            nextX += width + 16

            button.setTitle(titleText, for: .normal)
            button.addTarget(self, action: #selector(toggle(button:)), for: .touchUpInside)
            button.tag = index
            return button
        })
        
        toggleButtons.forEach({ contentView.addSubview($0) })
        
        let height = nextY + 48
        knownHeight = height
        return height
    }
    
    // MARK: Actions
    
    @objc private func toggle(button: ToggleButton) {
        button.isSelected = !button.isSelected
        
        if toggleType == .radio {
            var buttonsToUnselect = toggleButtons
            buttonsToUnselect.removeAll(where: { $0 == button })
            buttonsToUnselect.forEach({ $0.isSelected = false })
        }
        
        delegate?.didSelectButtonToggle(self, button: button, selection: buttonTitles[button.tag])
    }
    
    // MARK: Public Properties
    
    public var enabledButtons: [String]? {
        didSet {
            let buttonsToEnable = toggleButtons.compactMap({
                button -> ToggleButton? in
                
                let buttonFound = self.enabledButtons?.contains(button.titleLabel?.text ?? "") ?? false
                guard buttonFound else {
                    return nil
                }
                return button
            })
            buttonsToEnable.forEach({ $0.isSelected = true })
        }
    }
    
    public var buttonToggleType: ToggleType {
        get {
            return toggleType
        }
        set {
            toggleType = newValue
        }
    }
    
}

// MARK: - ToggleButtonContainerTableViewCellDelegate

public protocol ToggleButtonContainerTableViewCellDelegate: AnyObject {
    func didSelectButtonToggle(_ toggleButtonContainerTableViewCell: ToggleButtonContainerTableViewCell, button: ToggleButton, selection: String)
}
