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
    
    func updateView() {
        nameField?.text = crowd?.name
        membersLabel?.text = "\((crowd?.members.count ?? 1)-1) members"
        iconImageView?.image = crowd?.image
        iconImageView?.alternativeInfo = crowd?.name.initials
    }
    
    override func accessoryTypeForIndexPath(indexPath: NSIndexPath) -> UITableViewCellAccessoryType {
        if (indexPath.section == 1 || indexPath.section == 2) && indexPath.row == 0 {
            return .None
        }

        return .DisclosureIndicator
    }
    
    internal func addMember() {
        let alertView = UIAlertView(title: "Add member", message: "Please provide a valid user name", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alertView.alertViewStyle = .PlainTextInput
        alertView.show()
    }
    
    internal func leaveCrowd() {
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Removing user", inView: self.view)
        DataHandler.removeUser(User.localUser!._id, fromCrowd: crowd!) { (isSuccess) -> Void in
            activityIndicatorView.stop()
            if isSuccess {
                let indexOfRemovedUser = self.indexOfUser(User.localUser!._id)!
                let indexPath = NSIndexPath(forRow: indexOfRemovedUser, inSection: 1)
                self.tableViewDataSource.removeItemForIndexPath(indexPath)
                self.tableView?.reloadData()
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
        
        let leaveButton = Button(
            title:      "Leave group",
            image:      UIImage(named: "remove"),
            buttonStyle: .Danger
        )
        
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
                }
                
                print(isSuccess ? "Added member" : "Failed to add member")
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCrowdShelf" {
            let crowdShelfVC = segue.destinationViewController as! CrowdBookCollectionViewController
            crowdShelfVC.crowd = self.crowd
        }
    }
    
}