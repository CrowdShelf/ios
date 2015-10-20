//
//  CSBookViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//
import UIKit
import RealmSwift


class BookViewController: BaseViewController {
    
//    MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorsLabel: UILabel?
    @IBOutlet weak var publisherLabel: UILabel?
    
    @IBOutlet weak var coverImageView: AlternativeInfoImageView?
    
//    MARK: - Properties
    
    var book : Book? {
        didSet {
            self.updateView()
            
            if book?.details == nil {
                DataHandler.informationAboutBook(book!.isbn, withCompletionHandler: { (information) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if information.count > 1 {
                            self.showListWithItems(information, andCompletionHandler: { (information) -> Void in
                                Realm.write { realm -> Void in
                                    self.book?.details = information.first as? BookInformation
                                }
                                
                                self.updateView()
                            })
                        } else {
                            Realm.write { realm -> Void in
                                self.book?.details = information.first
                            }
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
    }
    
    func updateView() {
        
        self.coverImageView?.image = self.book?.details?.thumbnail
        self.titleLabel?.text = self.book?.details?.title
        self.publisherLabel?.text = self.book?.details?.publisher
        self.coverImageView?.alternativeInfo = self.book?.title.initials
        if self.book?.details != nil {
            self.authorsLabel?.text = self.book?.details?.authors.map {$0.stringValue!}.joinWithSeparator(", ")
        }
    }
    
    func newBook() -> Book {
        let newBook = Book()
        newBook.owner = User.localUser!._id
        newBook.details = self.book?.details
        newBook.isbn = self.book!.isbn
        
        return newBook
    }
    
    @IBAction func addBookToShelf(sender: AnyObject) {
        
        csprint(CS_DEBUG_BOOK_VIEW, "Adding book:", self.book)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Adding book", inView: self.view)
        
        DataHandler.addBook(self.newBook()) { (book) -> Void in
            activityIndicatorView.stop()
            
            self.book = book
            
            let message = book != nil ? "Successfully added book" : "Failed to add book"
            MessagePopupView(message: message, messageStyle: book != nil ? .Success : .Error).showInView(self.view)
            csprint(CS_DEBUG_BOOK_VIEW, message, self.book)
            
            self.updateView()
        }
       
        Analytics.addEvent("BookAdded")
        Analytics.addBookProperties(self.book!)
    }
    
    @IBAction func removeBookFromShelf(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Removing book:", self.book)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Removing book", inView: self.view)
        
        DataHandler.removeBook(self.book!._id) { (isSuccess) -> Void in
            activityIndicatorView.stop()
            
            let message = isSuccess ? "Successfully removed book" : "Failed to remove book"
            csprint(CS_DEBUG_BOOK_VIEW, message, self.book)
            MessagePopupView(message: message, messageStyle: isSuccess ? .Success : .Error).showInView(self.view)
            
            if isSuccess {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func borrow(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Borrowing book:", self.book)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Collecting information", inView: self.view)
        
        /* Retrieve users in possession of the book */
        DataHandler.ownersOfBooksWithParameters(["isbn": self.book!.isbn, "availableForRent": true]) { (owners) -> Void in
            activityIndicatorView.stop()
            
            /* Abort is no users are in possession of the book */
            if owners.count == 0 {
                MessagePopupView(message: "You cant borrow this book", messageStyle: .Error).showInView(self.view)
                return
            }
            
            /* Borrow book if only one user is in possession of the book */
            if owners.count == 1 {
                self.borrowBookFromUser(owners.first!._id)
                return
            }
            
            /* Present a list of all users in possession of the book */
            self.showListWithItems(owners, andCompletionHandler: { (selectedOwners) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                
                if selectedOwners.isEmpty {
                    csprint(CS_DEBUG_BOOK_VIEW, "Canceled borrow book:", self.book)
                    return
                }
                
                let owner = selectedOwners.first as! User
                self.borrowBookFromUser(owner._id)
            })
            
        }
        Analytics.addEvent("BorrowBook")
    }
    
    private func borrowBookFromUser(userID: String) {
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Borrowing book..", inView: self.view)
        
        DataHandler.addRenter(User.localUser!._id, toTitle: self.book!.isbn, withOwner: userID, withCompletionHandler: { (isSuccess) -> Void in
            activityIndicatorView.stop()
            
            let message = isSuccess ? "Sucessfully borrowed book" : "Failed to borrow book"
            csprint(CS_DEBUG_BOOK_VIEW, message, self.book)
            MessagePopupView(message: message, messageStyle: isSuccess ? .Success : .Error).showInView(self.view)
        })
    }
    
    @IBAction func returnBook(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Returning book:", self.book)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Collecting information", inView: self.view)
        
        DataHandler.ownersOfBooksWithParameters(["isbn":self.book!.isbn, "rentedTo": User.localUser!._id]) { (owners) -> Void in
            activityIndicatorView.stop()
            
            /* Abort is no users are in possession of the book */
            if owners.count == 0 {
                MessagePopupView(message: "You are not borrowing this book", messageStyle: .Error).showInView(self.view)
                return
            }
            
            /* Borrow book if only one user is in possession of the book */
            if owners.count == 1 {
                self.returnBookToUser(owners.first!._id)
                return
            }
            
            /* Present a list of all users in possession of the book */
            self.showListWithItems(owners, andCompletionHandler: { (selectedOwners) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                
                if selectedOwners.isEmpty {
                    csprint(CS_DEBUG_BOOK_VIEW, "Canceled borrow book:", self.book)
                    return
                }
                
                let owner = selectedOwners.first as! User
                self.returnBookToUser(owner._id)
            })
        }
        Analytics.addEvent("ReturnBook")
    }
    
    private func returnBookToUser(userID: String) {
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Returning book..", inView: self.view)
        
        DataHandler.removeRenter(User.localUser!._id, fromTitle: self.book!.isbn, withOwner: userID) { (isSuccess) -> Void in
            activityIndicatorView.stop()
            
            let message = isSuccess ? "Sucessfully returned book" : "Failed to return book"
            csprint(CS_DEBUG_BOOK_VIEW, message, self.book)
            MessagePopupView(message: message, messageStyle: isSuccess ? .Success : .Error).showInView(self.view)
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