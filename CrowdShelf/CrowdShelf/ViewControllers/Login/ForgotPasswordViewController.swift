//
//  ForgotPasswordViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 17/11/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class ForgotPasswordViewControler: UIViewController {
    

    @IBOutlet weak var usernameField: UITextField!
    
    var textfieldDelegate: TextFieldDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textfieldDelegate = TextFieldDelegate(onReturn: { (textField) -> Bool in
            textField.resignFirstResponder()
        })
        
        usernameField.delegate = textfieldDelegate
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendMail(sender: AnyObject) {
        let activityIndicator = ActivityIndicatorView.showActivityIndicatorWithMessage("Trying to send you an email!")
        
        DataHandler.forgotPassword(usernameField!.text!) { (isSuccess) -> Void in
            activityIndicator.stop()
            
            let title = isSuccess ? "Success!" : "Obs!"
            let message = isSuccess ? "We have sent you an email with further instructions" : "We couldn't find you in our database. Are you sure your username is correct?"
            let cancelButtonTitle = isSuccess ? "OK!" : "Darn"
            
            AlertView(style: .Default, title: title, message: message, cancelButtonTitle: cancelButtonTitle).show()
            
            if isSuccess {
                self.performSegueWithIdentifier("ShowSetPasswordView", sender: nil)
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSetPasswordView" {
            let updatePasswordVC = segue.destinationViewController as! UpdatePasswordViewController
            let view = updatePasswordVC.view
            updatePasswordVC.usernameField.text = usernameField.text
        }
    }
}