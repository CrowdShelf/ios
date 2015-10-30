//
//  MessagePopupView.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 29/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

enum MessagePopupStyle: Int {
    case Normal
    case Success
    case Error
    case Warning
    
    func textColor() -> UIColor {
        return UIColor.blackColor()
        
        switch self {
        case .Normal:
            return UIColor.blackColor()
        case .Success:
            return UIColor.greenColor()
        case .Error:
            return UIColor.redColor()
        case .Warning:
            return UIColor.yellowColor()
        }
    }
}

class MessagePopupView: UIVisualEffectView {
    
    let message: String
    let style: MessagePopupStyle
    
    private var topSpaceConstraint: NSLayoutConstraint?
    
    
    init(message: String, messageStyle: MessagePopupStyle = .Normal) {
        self.message = message
        self.style = messageStyle
        
        super.init(effect: UIBlurEffect(style: .ExtraLight))
        
        self.initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.message = ""
        self.style = .Normal
        
        super.init(coder: aDecoder)
        self.initializeView()
    }
    
    private func initializeView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addLabel()
        addSeparator()
    }
    
    private func addSeparator() {
        let separator = UIView()
        separator.backgroundColor = UIColor.lightGrayColor()
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(separator)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[separator]|", options: .AlignAllBaseline, metrics: nil, views: ["separator": separator]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[separator(1)]|", options: .AlignAllBaseline, metrics: nil, views: ["separator": separator]))
    }
    
    private func addLabel() {
        let label = UILabel()
        label.text = message
        label.textColor = self.style.textColor()
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(label)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: .AlignAllBaseline, metrics: nil, views: ["label": label]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[label]|", options: .AlignAllBaseline, metrics: nil, views: ["label": label]))
    }
    
    
    private func slideIn(completionHandler: ((Bool)->Void)?) {
        self.hidden = false
        
        self.superview?.layoutIfNeeded()
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            self.topSpaceConstraint?.constant = 0
            self.superview?.layoutIfNeeded()
          }) { (finished) -> Void in
            completionHandler?(finished)
        }
    }
    
    private func slideOut(completionHandler: ((Bool)->Void)?) {
        self.hidden = false
        
        self.superview?.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.topSpaceConstraint?.constant = -64
            self.superview?.layoutIfNeeded()
            }) { (finished) -> Void in
                completionHandler?(finished)
        }
    }
    

    
    func show() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let view = UIApplication.sharedApplication().keyWindow!.subviews.first!
            
            view.addSubview(self)
            
            /* Add constraints */
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[messageView]|", options: .AlignAllBaseline, metrics: nil, views: ["messageView":self]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[messageView(64)]", options: .AlignAllCenterY, metrics: nil, views: ["messageView":self]))
            
            self.topSpaceConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(-64)-[messageView]", options: .AlignAllCenterY, metrics: nil, views: ["messageView":self]).first!
            view.addConstraint(self.topSpaceConstraint!)
            
            /* Slide in and out */
            self.slideIn({ (finished) -> Void in
                Utilities.delayDispatchInQueue(dispatch_get_main_queue(), delay: 1.0, block: { () -> Void in
                    self.slideOut(nil)
                })
            })
        }
    }
}