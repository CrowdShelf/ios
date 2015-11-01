//
//  AlertView.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 01/11/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class AlertView: UIAlertView, UIAlertViewDelegate {
    
    var onDismiss: ((UIAlertView, Int) -> Void)?

    convenience init(style: UIAlertViewStyle = .Default,
        title: String,
        message: String,
        cancelButtonTitle: String,
        otherButtonTitles firstButtonTitle: String, _ moreButtonTitles: String...,
        onDismiss: ((UIAlertView, Int) -> Void)? = nil) {
        
        self.init(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: firstButtonTitle)
        
        moreButtonTitles.forEach {addButtonWithTitle($0)}
          
        self.onDismiss = onDismiss
        delegate = self
        alertViewStyle = style
    }
    
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        onDismiss?(alertView, buttonIndex)
    }
}