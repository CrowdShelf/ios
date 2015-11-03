//
//  CrowdViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class CrowdViewController: ListViewController, UIAlertViewDelegate, ListViewControllerDataSource, ListViewControllerDelegate {
    
    var crowd: Crowd? {
        didSet {
            retrieveUsers()
            updateView()
        }
    }
    
    @IBOutlet weak var iconImageView: AlternativeInfoImageView?
    @IBOutlet weak var nameField: UITextField?
    @IBOutlet weak var membersLabel: UILabel?
    
    var nameFieldDelegate: TextFieldDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameFieldDelegate = TextFieldDelegate { (textField) -> Bool in
            self.crowd?.name = textField.text!
            
            if self.crowd?._id != nil {
                DataHandler.updateCrowd(self.crowd!, withCompletionHandler: nil)
            }
            
            textField.resignFirstResponder()
            self.updateView()
            
            return true
        }
        
        self.dataSource = self
        self.delegate = self
        
        if self.crowd == nil {
            self.crowd = newCrowd()
        }
        
        self.updateView()
        self.updateItemsWithListables([])
        
        self.nameField?.delegate = nameFieldDelegate
    }
    
    func newCrowd() -> Crowd {
        let crowd = Crowd()
        crowd.name = "New Group"
        crowd.owner = User.localUser!._id
        
        return crowd
    }
    
    internal func retrieveUsers() {
        DataHandler.getMembersOfCrowd(crowd!) {[unowned self] (users) -> Void in
            self.updateItemsWithListables(users)
        }
    }
    
    /// Creates a new crowd with name and members defined by the user
    func createCrowd(){
        Analytics.addEvent("CreateCrowd")
        
        DataHandler.createCrowd(self.crowd!, withCompletionHandler: { (crowd) -> Void in
            if crowd != nil {
                self.crowd = crowd
                self.updateView()
            }
        })
    }
    
    func updateView() {
        nameField?.text = crowd?.name
        membersLabel?.text = "\(crowd?.members.count ?? 0) members"
        iconImageView?.image = crowd?.image
        iconImageView?.alternativeInfo = crowd?.name?.initials
        iconImageView?.tintColor = ColorPalette.colorForString(self.crowd!._id ?? "")
    }
    
    internal func addMember() {
        Analytics.addEvent("AddMember")
        
        AlertView(style: .PlainTextInput,
                  title: "Add member",
                message: "Please provide a valid user name",
      cancelButtonTitle: "Cancel",
      otherButtonTitles: "OK") { (alertView, buttonIndex) -> Void in
            
            switch buttonIndex {
            case alertView.cancelButtonIndex:
                break
            default:
                let username = alertView.textFieldAtIndex(0)!.text!
                
                let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Adding \"\(username)\"", inView: self.view)
                DataHandler.addUserWithUsername(username, toCrowd: self.crowd!._id!, withCompletionHandler: { (userID, isSuccess) -> Void in
                    
                    if isSuccess {
                        DataHandler.getCrowd(self.crowd!._id!) { (crowd) -> Void in
                            activityIndicatorView.stop()
                            self.crowd = crowd
                        }
                    } else {
                        activityIndicatorView.stop()
                        MessagePopupView(message: "Failed add member", messageStyle: .Error).show()
                    }
                })
            }
        }.show()
    }
    
    internal func leaveCrowd() {
        AlertView(title: "Leave crowd",
                message: "Are you sure?",
      cancelButtonTitle: "No",
      otherButtonTitles: "Leave") { (alertView, buttonIndex) -> Void in
            if buttonIndex == alertView.cancelButtonIndex {
                return
            }
            
            let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Leaving crowd", inView: self.view)
            DataHandler.removeUser(User.localUser!._id!, fromCrowd: self.crowd!) { (isSuccess) -> Void in
                activityIndicatorView.stop()
                if isSuccess {
                    self.navigationController?.popViewControllerAnimated(true)
                    Analytics.addEvent("LeaveCrowd")
                }
            }
        }.show()
    }
    
    internal func updateItemsWithListables(listables: [Listable]) {
        
        let shelfButton = Button(
            title:      "Shelf",
            image:      UIImage(named: "shelf")
        )
        
        let newMemberButton = Button(
            title:     "Add member",
            image:     UIImage(named: "add")
        )
        
        let membersSection: [AnyObject] = [newMemberButton]+listables
        
        
        let leaveButton:Button = Button(
            title:      "Leave group",
            image:      UIImage(named: "remove"),
            buttonStyle: .Danger
        )
        
        let createButton = Button(
            title:      "Create group",
            image:      UIImage(named: "add")
        )
        
        
        tableViewDataSource.items = crowd?._id != nil ? [[shelfButton], membersSection, [leaveButton]] : [createButton]
        tableView?.performSelectorOnMainThread("reloadData", withObject: nil, waitUntilDone: false)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCrowdShelf" {
            let crowdShelfVC = segue.destinationViewController as! CrowdBookCollectionViewController
            crowdShelfVC.crowd = self.crowd
        }
    }
    
//    MARK: List View Data Source
    
    func listViewController(listViewController: ListViewController, accessoryTypeForIndexPath indexPath: NSIndexPath) -> UITableViewCellAccessoryType {
        if indexPath.section == 0 && crowd?._id != nil {
            return .DisclosureIndicator
        }
        
        return .None
    }
    
    func listViewController(listViewController: ListViewController, shouldShowSubtitleForCellAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row > 0
    }
    
//    MARK: List View Delegate
    
    func listViewController(listViewController: ListViewController, performActionForIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if crowd?._id == nil {
                createCrowd()
                return
            }
            
            if indexPath.row == 0 {
                performSegueWithIdentifier("ShowCrowdShelf", sender: self)
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                addMember()
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                leaveCrowd()
            }
        }
    }
}