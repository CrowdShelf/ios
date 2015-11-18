//
//  UpdatePasswordViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 17/11/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var keyInputField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmNewPasswordField: UITextField!
    
    var textfieldDelegate: TextFieldDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textfieldDelegate = TextFieldDelegate(onReturn: { (textField) -> Bool in
            textField.resignFirstResponder()
        })
        
        usernameField.delegate = textfieldDelegate
        keyInputField.delegate = textfieldDelegate
        newPasswordField.delegate = textfieldDelegate
        confirmNewPasswordField.delegate = textfieldDelegate
    }
    
    @IBAction func updatePassword(sender: AnyObject) {
        if !inputIsValid() {
            return
        }
        
        DataHandler.resetPasswordForUser(usernameField.text!, password: newPasswordField.text!, key: keyInputField.text!) { (isSuccess) -> Void in
            if isSuccess {
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                AlertView(title: "Oh, no!", message: "Something went wrong! Are you sure the key and username is correct?", cancelButtonTitle: "Maybe not").show()
            }
        }
        
    }
    
    private func inputIsValid() -> Bool {
        let keyIsValid = keyInputField.text != nil && keyInputField.text!.characters.count > 2
        let passwordsMatch = newPasswordField.text != nil && newPasswordField.text == confirmNewPasswordField.text
        
        return keyIsValid && passwordsMatch
    }
}
