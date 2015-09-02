//
//  CSTextView.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 02/09/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class CSTextView: UITextView {
    
    @IBInspectable var padding : Bool = true {
        didSet {
            self.textContainerInset                 =   self.padding ? UIEdgeInsetsMake(8, 0, 8, 0) : UIEdgeInsetsZero
            self.textContainer.lineFragmentPadding  =   self.padding ? 5                            : 0
        }
    }
}