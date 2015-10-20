//
//  ReturnTextFieldDelegate.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class ReturnTextFieldDelegate: NSObject, UITextFieldDelegate {
    typealias ReturnHandler = ((textField: UITextField) -> Void)
    
    
    var returnHandler: ReturnHandler
    
    init(returnHandler: ReturnHandler) {
        self.returnHandler = returnHandler
        super.init()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.returnHandler(textField: textField)
        return true
    }
}
