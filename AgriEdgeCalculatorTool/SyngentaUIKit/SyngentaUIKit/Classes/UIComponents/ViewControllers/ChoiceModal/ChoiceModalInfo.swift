//
//  ChoiceModalInfo.swift
//  SyngentaUIKit
//
//  Created by Matt Jankowiak on 9/19/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

public struct ChoiceModalInfo {
    let titleLabel: String
    let subtitleLabel: String
    let closeButtonTitle: String
    let choiceButtonTitles: [String]?
    
    public init(titleLabel: String, subtitleLabel: String, closeButtonTitle: String, choiceButtonTitles: [String]?) {
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.closeButtonTitle = closeButtonTitle
        self.choiceButtonTitles = choiceButtonTitles
    }
}
