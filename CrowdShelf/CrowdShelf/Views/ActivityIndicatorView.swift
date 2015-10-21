//
//  ActivityIndicatorView.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 29/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIView {
    
    let activityIndicator   = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let messageLabel        = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureView()
        
    }
    
    private func configureView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.messageLabel.textAlignment = NSTextAlignment.Center
        
        self.addSubview(self.messageLabel)
        self.addSubview(self.activityIndicator)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[indicator]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["indicator": self.activityIndicator]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-250-[indicator(40)]", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["indicator": self.activityIndicator]))
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["label": self.messageLabel]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[indicator][label(80)]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["label": self.messageLabel, "indicator": self.activityIndicator]))
    }
    
    func startInView(view: UIView, withMessage message: String?) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            view.addSubview(self)
            
            self.messageLabel.text = message
            
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view": self]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view": self]))
            
            self.activityIndicator.startAnimating()
        }
    }
    
    func startInView(view: UIView) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.startInView(view, withMessage: nil)
        }
    }
    
    func stop() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        }
    }
    
    class func showActivityIndicatorWithMessage(message: String?, inView view: UIView) -> ActivityIndicatorView {
        let activityIndicatorView = ActivityIndicatorView(frame: view.bounds)
        
        activityIndicatorView.startInView(view, withMessage: message)
        
        return activityIndicatorView
    }
    
}