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
    
    var textfieldDelegate: TextFieldDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textfieldDelegate = TextFieldDelegate(onReturn: { (textField) -> Bool in
            textField.resignFirstResponder()
        })
        
        usernameField?.delegate = textfieldDelegate
        passwordField?.delegate = textfieldDelegate
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        navigationController?.navigationBar.tintColor = ColorPalette.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : ColorPalette.whiteColor()]
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func login(sender: AnyObject?) {
        self.view.endEditing(true)
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