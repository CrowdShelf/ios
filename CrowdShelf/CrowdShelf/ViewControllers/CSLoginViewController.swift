//
//  CSLoginViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 23/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class CSLoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(sender: AnyObject) {
    }
    
    @IBAction func login(sender: AnyObject) {
        let value = [
            "username": self.usernameField.text!,
            "email": self.emailField.text!,
            "name": self.nameField.text!,
        ]
        let user = CSUser(value: value)
        
        if self.segmentedControl.selectedSegmentIndex == 1 {
            CSDataHandler.createUser(user, withCompletionHandler: { (user) -> Void in

                if user != nil {
                    CSLocalDataHandler.setObject(user!.serialize() , forKey: "user", inFile: CSLocalDataFile.User)
                    CSUser.localUser = user
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
}