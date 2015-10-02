//
//  LoginViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 23/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        self.emailField.hidden = sender.selectedSegmentIndex == 0
        self.nameField.hidden = sender.selectedSegmentIndex == 0
    }
    
    @IBAction func login(sender: AnyObject) {
        let value = [
            "username": self.usernameField.text!,
            "email": self.emailField.text!,
            "name": self.nameField.text!,
        ]
        let user = User(value: value)
        
        if self.segmentedControl.selectedSegmentIndex == 1 {
            DataHandler.createUser(user, withCompletionHandler: { (user) -> Void in

                if user != nil {
                    LocalDataHandler.setObject(user!.serialize() , forKey: "user", inFile: LocalDataFile.User)
                    User.localUser = user
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        } else {
            DataHandler.loginWithUsername(self.usernameField.text!) { user -> Void in
                if user == nil {
                    self.segmentedControl.selectedSegmentIndex = 1
                    self.segmentChanged(self.segmentedControl)
                    return
                }
                
                LocalDataHandler.setObject(user!.serialize() , forKey: "user", inFile: LocalDataFile.User)
                User.localUser = user
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
    }
}