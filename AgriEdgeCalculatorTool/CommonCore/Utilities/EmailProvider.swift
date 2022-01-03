//
//  EmailProvider.swift
//  AgriEdgeCalculatorTool
//
//  Created by Matt Jankowiak on 10/16/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import UIKit

class EmailProvider: UIActivityItemProvider {
    let subject: String
    let message: String
    
    init(subject: String, message: String) {
        self.subject = subject
        self.message = message
        
        super.init(placeholderItem: message)
    }
    
    override func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return message
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return message
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return subject
    }
    
}
