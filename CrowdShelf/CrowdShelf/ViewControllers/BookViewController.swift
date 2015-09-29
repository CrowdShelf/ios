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


class BookViewController: BaseViewController {
    
//    MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorsLabel: UILabel?
    @IBOutlet weak var publisherLabel: UILabel?
    
    @IBOutlet weak var coverImageView: UIImageView?
    
//    MARK: - Properties
    
    var book : Book? {
        didSet {
            self.updateView()
            
            if book?.details == nil {
                DataHandler.informationAboutBook(book!.isbn, withCompletionHandler: { (information) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if information.count > 1 {
                            self.showListWithItems(information, andCompletionHandler: { (information) -> Void in
                                self.book?.details = information.first as? BookInformation
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateView", name: Notification.LocalUserUpdated, object: nil)
        
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
    }
    
    @IBAction func addBookToShelf(sender: AnyObject) {
        let newBook = Book()
        newBook.owner = User.localUser!._id
        newBook.details = self.book?.details
        newBook.isbn = self.book!.isbn
        
        self.book = newBook
        
        csprint(CS_DEBUG_BOOK_VIEW, "Adding book:", self.book)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Searching for information", inView: self.view)
        
        DataHandler.addBook(self.book!) { (isSuccess) -> Void in
            activityIndicatorView.stop()
            
            let message = isSuccess ? "Successfully added book" : "Failed to add book"
            
            MessagePopupView(message: message, messageStyle: isSuccess ? .Success : .Error).show()
            
            csprint(CS_DEBUG_BOOK_VIEW, message, self.book)
            
            self.updateView()
        }
        
        Mixpanel.sharedInstanceWithToken(CS_ENVIRONMENT.MixpanelTracking())
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
//        let categories = self.book?.details?.categories.map {$0.content as! String}
        
        mixpanel.track("BookAdded")

        
    }
    
    @IBAction func removeBookFromShelf(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Removing book:", self.book)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Searching for information", inView: self.view)
        
        DataHandler.removeBook(self.book!._id) { (isSuccess) -> Void in
            activityIndicatorView.stop()
            
            let message = isSuccess ? "Successfully removed book" : "Failed to remove book"
            csprint(CS_DEBUG_BOOK_VIEW, message, self.book)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func borrow(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Borrowing book:", self.book)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Collecting information", inView: self.view)
        
        DataHandler.getBooksWithParameters(["isbn":self.book!.isbn]) { (books) -> Void in
            var ownerMapping: [String: [Book]] = [:]
            
            for book in books {
                if ownerMapping[book.owner] == nil {
                    ownerMapping[book.owner] = [book]
                } else {
                    ownerMapping[book.owner]?.append(book)
                }
            }
            
            DataHandler.usersWithCompletionHandler { users -> Void in
                activityIndicatorView.stop()
                let owners = users.filter {ownerMapping.keys.contains($0._id)}
                
                self.showListWithItems(owners, andCompletionHandler: { (selectedOwners) -> Void in
                    if selectedOwners.isEmpty {
                        csprint(CS_DEBUG_BOOK_VIEW, "Canceled borrow book:", self.book)
                        return self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    let owner = selectedOwners.first as! User
                    DataHandler.addRenter(owner._id, toBook: ownerMapping[owner._id]!.first!._id, withCompletionHandler: { (isSuccess) -> Void in
                        csprint(CS_DEBUG_BOOK_VIEW, "Successfully borrowed book:", self.book)
                        
                        MessagePopupView(message: "Book borrowed", messageStyle: isSuccess ? .Success : .Error).show()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                })
            }
        }
    }
    
    @IBAction func returnBook(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Returning book:", self.book)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Collecting information", inView: self.view)
        DataHandler.getBooksWithParameters(["isbn":self.book!.isbn, "rentedTo": User.localUser!._id]) { (books) -> Void in
            var ownerMapping: [String: [Book]] = [:]
            
            for book in books {
                if ownerMapping[book.owner] == nil {
                    ownerMapping[book.owner] = [book]
                } else {
                    ownerMapping[book.owner]?.append(book)
                }
            }
            
            DataHandler.usersWithCompletionHandler { users -> Void in
                activityIndicatorView.stop()
                let owners = users.filter {ownerMapping.keys.contains($0._id)}
                
                self.showListWithItems(owners, andCompletionHandler: { (selectedOwners) -> Void in
                    
                    if selectedOwners.isEmpty {
                        csprint(CS_DEBUG_BOOK_VIEW, "Canceled return book:", self.book)
                        return self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    let owner = selectedOwners.first as! User
                    DataHandler.removeRenter(User.localUser!._id, fromBook: ownerMapping[owner._id]!.first!._id, withCompletionHandler: { (isSuccess) -> Void in
                        csprint(CS_DEBUG_BOOK_VIEW, "Successfully returned book:", self.book)
                        
                        MessagePopupView(message: "Book returned", messageStyle: isSuccess ? .Success : .Error).show()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                })
            }
        }
    }
    
//    MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBookInformation" {
            let bookInformationVC = segue.destinationViewController as! BookInformationViewController
            bookInformationVC.bookInformation = self.book?.details
        }
    }
}