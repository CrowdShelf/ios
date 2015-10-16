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
    
    func color() -> UIColor {
        switch self {
        case .Normal:
            return UIColor.grayColor()
        case .Success:
            return UIColor.greenColor()
        case .Error:
            return UIColor.redColor()
        case .Warning:
            return UIColor.yellowColor()
        }
    }
}

class MessagePopupView: UILabel {
    
    var style: MessagePopupStyle = .Normal
    
    init(message: String, messageStyle: MessagePopupStyle = .Normal) {
        super.init(frame: CGRectZero)
        
        self.text = message
        
        self.style = messageStyle
        
        self.initializeView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeView()
    }
    
    private func initializeView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = .Center
        self.textColor = UIColor.whiteColor()
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    private func fadeViewIn(fadeIn: Bool, completionHandler: ((Bool)->Void)?) {
        self.alpha = fadeIn ? 0 : 1
        self.hidden = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = fadeIn ? 1 : 0
            }) { (finished) -> Void in
                self.hidden = !fadeIn
                completionHandler?(finished)
        }
    }
    
    func showInView(view: UIView) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.backgroundColor = self.style.color().colorWithAlphaComponent(0.85)
            
            view.addSubview(self)
            
            /* Add constraints */
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: .AlignAllBaseline, metrics: nil, views: ["label":self]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label(44)]-(16)-|", options: .AlignAllCenterY, metrics: nil, views: ["label":self]))
            
            /* Fade in and out */
            self.fadeViewIn(true, completionHandler: { (_) -> Void in
                Utilities.delayDispatchInQueue(dispatch_get_main_queue(), delay: 0.8, block: { () -> Void in
                    self.fadeViewIn(false, completionHandler: { (_) -> Void in
                        self.removeFromSuperview()
                    })
                })
            })
        }
    }
}