//
//  ChoiceModalViewController.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 7/12/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

public class ChoiceModalViewController: UIViewController, StoryboardLoadable {
    
    // MARK: Outlets
    
    @IBOutlet private weak var modalView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var closeButton: StyledButton!
    @IBOutlet private weak var buttonStackView: UIStackView!
    
    // MARK: Properties
    
    public weak var delegate: ChoiceModalPresenting?
    
    public var choiceModalInfo: ChoiceModalInfo?
    
    // MARK: View Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        modalView.layer.cornerRadius = 4
        titleLabel.text = choiceModalInfo?.titleLabel
        subtitleLabel.text = choiceModalInfo?.subtitleLabel
        closeButton.setTitle(choiceModalInfo?.closeButtonTitle, for: .normal)
        closeButton.configure(buttonStyle: .tertiary, buttonColor: .teal)
        
        choiceModalInfo?.choiceButtonTitles?.map({
            (text: String) -> StyledButton in
            
            let button = StyledButton()
            button.configure(buttonStyle: .tertiary, buttonColor: .black)
            button.setTitle(text, for: .normal)
            button.heightAnchor.constraint(equalToConstant: 40).isActive = true
            button.addTarget(self, action: #selector(select(button:)), for: .touchUpInside)
            return button
        }).reversed().forEach({
            buttonStackView.insertArrangedSubview($0, at: 0)
        })
    }
    
    // MARK: Actions
    
    @IBAction private func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func select(button: StyledButton) {
        delegate?.choiceModalDidSelectItem(self, selection: button.titleLabel?.text)
        dismiss(animated: true, completion: nil)
    }

}
