//
//  MinimalTextField.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class MinimalTextField: UITextField {
    
    override func awakeFromNib() {
        borderStyle = .None
    }
    
    override func becomeFirstResponder() -> Bool {
        borderStyle = .RoundedRect
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        borderStyle = .None
        
        return super.resignFirstResponder()
    }
    
}
