//
//  RegisterUserViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 30/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class RegisterUserViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    @IBOutlet weak var confirmPasswordField: UITextField?
    @IBOutlet weak var emailField: UITextField?
    @IBOutlet weak var nameField: UITextField?
    
    @IBAction func register() {
        if passwordField?.text != confirmPasswordField?.text {
            return
        }
        
        let value = [
            "username": self.usernameField!.text!,
            "password": self.passwordField!.text!,
            "email":    self.emailField!.text!,
            "name":     self.nameField!.text!
        ]
        
        let user = User(value: value)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Logging in..", inView: self.view)
        
        DataHandler.createUser(user, withCompletionHandler: { (user) -> Void in
            activityIndicatorView.stop()
            
            if user != nil {
                User.loginUser(user!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
    
    func isValidInput() -> Bool {
        return isValidUsername() && isValidPassword() && isValidEmail()
    }
    
    func isValidEmail() -> Bool {
        return emailField?.text != nil &&
               emailField!.text!.containsString("@")
               emailField!.text!.characters.count >= 5
    }
    
    func isValidPassword() -> Bool {
        return  passwordField?.text != nil &&
                confirmPasswordField?.text != nil &&
                passwordField!.text!.characters.count >= 6 &&
                passwordField!.text! == confirmPasswordField!.text!
    }
    
    func isValidUsername() -> Bool {
        return usernameField?.text?.characters.count >= 6
    }
}
