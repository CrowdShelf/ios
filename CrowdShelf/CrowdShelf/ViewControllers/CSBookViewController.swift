//
//  CSBookViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//
import Mixpanel
import UIKit
import RealmSwift


class CSBookViewController: CSBaseViewController {
    
//    MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorsLabel: UILabel?
    @IBOutlet weak var publisherLabel: UILabel?
    
    @IBOutlet weak var coverImageView: UIImageView?
    
    @IBOutlet weak var bookView: UIView!
    
    @IBOutlet var buttons: [UIButton]?
    
//    MARK: - Properties
    
    var book : CSBook? {
        didSet {
            self.updateView()
            
            if book?.details == nil {
                CSDataHandler.informationAboutBook(book!.isbn, withCompletionHandler: { (information) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if information.count > 1 {
                            self.showListWithItems(information, andCompletionHandler: { (information) -> Void in
                                self.book?.details = information.first as? CSBookInformation
                                self.updateView()
                            })
                        } else {
                            self.book?.details = information.first
                        }
                        
                        self.updateView()
                    })
                })
            }
        }
    }
    
//    MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateView", name: CSNotification.LocalUserUpdated, object: nil)
        
        self.coverImageView?.layer.borderWidth = 1
        self.coverImageView?.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    func updateView() {
        
        self.coverImageView?.image = self.book?.details?.thumbnail
        self.titleLabel?.text = self.book?.details?.title
        self.publisherLabel?.text = self.book?.details?.publisher
        
        
        if self.book?.details != nil {
            self.authorsLabel?.text = self.book?.details?.authors.map {$0.stringValue!}.joinWithSeparator(", ")
        }
        
        if self.buttons != nil {
            for button in self.buttons! {
                button.enabled = CSUser.localUser != nil
            }
        }
        
    }
    
    @IBAction func addBookToShelf(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Adding book:", self.book)

        self.book!.owner = CSUser.localUser!._id
        
        CSDataHandler.addBook(self.book!) { (isSuccess) -> Void in
            if isSuccess {
                csprint(CS_DEBUG_BOOK_VIEW, "Successfully added book:", self.book)
            } else {
                csprint(CS_DEBUG_BOOK_VIEW, "Failed to add book:", self.book)
            }
            
            self.updateView()
        }
        
        Mixpanel.sharedInstanceWithToken(CS_ENVIRONMENT.MixpanelTracking())
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
//        let categories = self.book?.details?.categories.map {$0.content as! String}
        
        mixpanel.track("BookAdded")

        
    }
    
    @IBAction func removeBookFromShelf(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Removing book:", self.book)
        
        CSDataHandler.removeBook(self.book!._id) { (isSuccess) -> Void in
            if isSuccess {
                csprint(CS_DEBUG_BOOK_VIEW, "Successfully removed book:", self.book)
            } else {
                csprint(CS_DEBUG_BOOK_VIEW, "Failed to remove book:", self.book)
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBookInformation" {
            let bookInformationVC = segue.destinationViewController as! CSBookInformationViewController
            bookInformationVC.bookInformation = self.book?.details
        }
    }
}