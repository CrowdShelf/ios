//
//  TextFieldReturnDelegate.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 30/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    typealias BooleanHandler = ( (UITextField) -> Bool )
    
    var onReturn            : BooleanHandler
    var onClear             : BooleanHandler?
    var onShouldBeginEditing: BooleanHandler?
    var onShouldEndEditing  : BooleanHandler?
    var onDidBeginEditing    : BooleanHandler?
    var onDidEndEditing     : BooleanHandler?
    
    init(onReturn: BooleanHandler) {
        self.onReturn = onReturn
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return self.onReturn(textField)
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return self.onClear?(textField) ?? true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return self.onShouldBeginEditing?(textField) ?? true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return self.onShouldEndEditing?(textField) ?? true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        onDidBeginEditing?(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        onDidEndEditing?(textField)
    }
}