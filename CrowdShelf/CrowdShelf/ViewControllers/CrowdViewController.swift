//
//  CrowdViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class CrowdViewController: ListViewController, UIAlertViewDelegate {
    
    var crowd: Crowd? {
        didSet {
            retrieveUsers()
            updateView()
        }
    }
    
    @IBOutlet weak var iconImageView: AlternativeInfoImageView?
    @IBOutlet weak var nameField: UITextField?
    @IBOutlet weak var membersLabel: UILabel?
    
    lazy var nameFieldDelegate: ReturnTextFieldDelegate = {
        return ReturnTextFieldDelegate { (textField) -> Void in
            self.crowd?.name = textField.text!
            
            DataHandler.updateCrowd(self.crowd!, withCompletionHandler: nil)
            
            textField.resignFirstResponder()
            self.updateView()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateView()
        
        self.tableViewDelegate.selectionHandler = {[unowned self] (_, indexPath, selected) -> Void in
            if selected {
                if indexPath.section == 0 && indexPath.row == 0 {
                    return self.performSegueWithIdentifier("ShowCrowdShelf", sender: self)
                }
                
                if indexPath.section == 1 && indexPath.row == 0 {
                    self.addMember()
                } else if indexPath.section == 2 && indexPath.row == 0 {
                    if self.crowd?._id == "" {
                        self.createCrowd()
                    }
                    self.leaveCrowd()
                }
            }
        }
        
        self.updateItemsWithListables([])
        
        self.nameField?.delegate = nameFieldDelegate
    }
    
    func newCrowd() -> Crowd {
        let crowd = Crowd()
        crowd.members.append(RLMWrapper(User.localUser!._id))
        crowd.name = "New Group"
        crowd.owner = User.localUser!._id
        Analytics.addEvent("CreateCrowd")
        return crowd
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.crowd == nil {
            self.crowd = newCrowd()
            
        }
    }
    
    internal func retrieveUsers() {
        DataHandler.getMembersOfCrowd(crowd!) {[unowned self] (users) -> Void in
            self.updateItemsWithListables(users)
        }
    }
    /// Creates a new crowd with name and members defined by the user
    func createCrowd(){
        DataHandler.createCrowd(self.crowd!, withCompletionHandler: { (crowd) -> Void in
            if crowd != nil {
                self.crowd = crowd
            }
        })
    }
    
    func updateView() {
        nameField?.text = crowd?.name
        membersLabel?.text = "\((crowd?.members.count ?? 0)) members"
        iconImageView?.image = crowd?.image
        iconImageView?.alternativeInfo = crowd?.name.initials
    }
    
    override func accessoryTypeForIndexPath(indexPath: NSIndexPath) -> UITableViewCellAccessoryType {
        if indexPath.section == 0 {
            return .DisclosureIndicator
        }

        return .None
    }
    
    internal func addMember() {
        let alertView = UIAlertView(title: "Add member", message: "Please provide a valid user name", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alertView.alertViewStyle = .PlainTextInput
        alertView.show()
        Analytics.addEvent("AddMember")
    }
    
    internal func leaveCrowd() {
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Removing user", inView: self.view)
        DataHandler.removeUser(User.localUser!._id, fromCrowd: crowd!) { (isSuccess) -> Void in
            activityIndicatorView.stop()
            if isSuccess {
                self.navigationController?.popViewControllerAnimated(true)
                Analytics.addEvent("LeaveCrowd")
            }
        }
    }
    
    func indexOfUser(userID: String) -> Int? {
        let index = (tableViewDataSource.items[1] as! [Listable]).indexOf({ (item) -> Bool in
            if let user = item as? User {
                return user._id == userID
            }
            return false
        })
        
        return index != nil ? Int(index!) : nil
    }
    
    internal func updateItemsWithListables(listables: [Listable]) {
        
        let shelfButton = Button(
            title:      "Shelf",
            image:      UIImage(named: "shelf")
        )
        // If it is a new group; Let the user create a group
        // Else the button lets you leave the group
        let leaveButton:Button
        if self.crowd?._id == ""{
            leaveButton = Button(
                title:      "Create group",
                image:      UIImage(named: "add")
            )
        }else {
            leaveButton = Button(
                title:      "Leave group",
                image:      UIImage(named: "remove"),
                buttonStyle: .Danger
            )
        }
        
        let newMemberButton = Button(
            title:     "Add member",
            image:     UIImage(named: "add")
        )
        
        let lastSection: [AnyObject] = [newMemberButton]+listables
        
        tableViewDataSource.items = [[shelfButton], lastSection, [leaveButton]]
        tableView?.reloadData()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        switch buttonIndex {
        case alertView.cancelButtonIndex:
            break
        default:
            let username = alertView.textFieldAtIndex(0)?.text
            
            let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Adding member", inView: self.view)
            DataHandler.addUserWithUsername(username!, toCrowd: crowd!._id, withCompletionHandler: { (userID, isSuccess) -> Void in
                
                if isSuccess {
                    self.crowd?.members.insert(RLMWrapper(userID!), atIndex: 0)
                    
                    DataHandler.getUser(userID!, withCompletionHandler: { (user) -> Void in
                        activityIndicatorView.stop()
                        
                        self.tableViewDataSource.addItem(user!, forIndexPath: NSIndexPath(forRow: 1, inSection: 1))
                        self.tableView?.reloadData()
                    })
                } else {
                    activityIndicatorView.stop()
                    MessagePopupView(message: "Failed add member", messageStyle: .Error).showInView(self.view)
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCrowdShelf" {
            let crowdShelfVC = segue.destinationViewController as! CrowdBookCollectionViewController
            crowdShelfVC.crowd = self.crowd
        }
    }
    /// When user press done button in 
    @IBAction func done(sender: AnyObject) {
        DataHandler.deleteCrowd(self.crowd!._id) { (isSuccess) -> Void in
            if isSuccess {
                self.navigationController?.popViewControllerAnimated(true)
                Analytics.addEvent("DeleteCrowd")
            } else {
                MessagePopupView(message: "Failed to delete crowd", messageStyle: .Error).showInView(self.view)
            }
        }
    }
    
}