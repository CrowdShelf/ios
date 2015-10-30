//
//  LoginViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 23/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    
    @IBAction func login(sender: AnyObject) {
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Logging in..", inView: self.view)
        

        DataHandler.loginWithUsername(self.usernameField!.text!, andPassword: self.passwordField!.text!) { user -> Void in
            activityIndicatorView.stop()
            
            self.passwordField?.text = ""
            
            if user != nil {
                User.loginUser(user!)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}