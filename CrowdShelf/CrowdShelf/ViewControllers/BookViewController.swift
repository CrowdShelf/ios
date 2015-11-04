//
//  CSBookViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//
import UIKit

class BookViewController: ListViewController {
    
//    MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorsLabel: UILabel?
    @IBOutlet weak var publisherLabel: UILabel?
    
    @IBOutlet weak var coverImageView: AlternativeInfoImageView?
    
//    MARK: - Properties
    
    var bookInformation : BookInformation? {
        didSet {
            self.updateView()
        }
    }
    
//    MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borrowBookButton = Button(title: "Borrow book", image: UIImage(named: "add"), buttonStyle: .Normal)
        let returnBookButton = Button(title: "Return book", image: UIImage(named: "remove"), buttonStyle: .Normal)
        let addBookButton = Button(title: "Add book", image: UIImage(named: "add"), buttonStyle: .Normal)
        let removeBookButton = Button(title: "Remove book", image: UIImage(named: "remove"), buttonStyle: .Normal)
        
        self.tableViewDataSource.items = [[borrowBookButton,returnBookButton,addBookButton,removeBookButton]]
        self.tableView?.reloadData()
        
        self.updateView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateView", name: Notification.LocalUserUpdated, object: nil)
        
        tableViewDelegate.selectionHandler = { [unowned self] (_, indexPath, selected) -> Void in
            if indexPath.section == 0 {
                switch indexPath.row {
                case 0:
                    self.borrow()
                case 1:
                    self.returnBook()
                case 2:
                    self.addBookToShelf()
                case 3:
                    self.removeBookFromShelf()
                default:
                    break
                }
            }
        }
    }
    
    func updateView() {
        coverImageView?.image           = bookInformation?.thumbnail
        titleLabel?.text                = bookInformation?.title
        publisherLabel?.text            = bookInformation?.publisher
        coverImageView?.alternativeInfo = bookInformation?.title?.initials
        authorsLabel?.text              = bookInformation?.authorsString
    }
    
    func newBook() -> Book {
        let newBook     = Book()
        newBook.owner   = User.localUser!._id
        newBook.isbn    = self.bookInformation!.isbn
        
        return newBook
    }
    
    func addBookToShelf() {
        
        csprint(CS_DEBUG_BOOK_VIEW, "Adding book:", self.bookInformation)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Adding book", inView: self.view)
        
        DataHandler.addBook(self.newBook()) { (book) -> Void in
            activityIndicatorView.stop()
            
            let message = book != nil ? "Successfully added book" : "Failed to add book"
            MessagePopupView(message: message, messageStyle: book != nil ? .Success : .Error).show()
            csprint(CS_DEBUG_BOOK_VIEW, message, self.bookInformation)
            
            self.updateView()
        }
       
        Analytics.addEvent("BookAdded")
        Analytics.addBookProperties(self.bookInformation!)
    }
    
    func removeBookFromShelf() {
        csprint(CS_DEBUG_BOOK_VIEW, "Removing book:", self.bookInformation)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Removing book", inView: self.view)
        
        DataHandler.removeBookForUser(User.localUser!._id!, withISBN: self.bookInformation!.isbn!) { (isSuccess) -> Void in
            activityIndicatorView.stop()
            
            let message = isSuccess ? "Successfully removed book" : "Failed to remove book"
            csprint(CS_DEBUG_BOOK_VIEW, message, self.bookInformation?.isbn)
            MessagePopupView(message: message, messageStyle: isSuccess ? .Success : .Error).show()
            
            if isSuccess {
                self.dismissViewControllerAnimated(true, completion: nil)
            }

        }
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func borrow() {
        csprint(CS_DEBUG_BOOK_VIEW, "Borrowing book:", self.bookInformation)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Collecting information", inView: self.view)
        
        /* Retrieve users in possession of the book */
        DataHandler.ownersOfBooksWithParameters(["isbn": self.bookInformation!.isbn!, "availableForRent": true]) { (owners) -> Void in
            activityIndicatorView.stop()
            
            let otherUsers = owners.filter {$0._id != User.localUser!._id}
            
            /* Abort is no users are in possession of the book */
            if otherUsers.count == 0 {
                MessagePopupView(message: "You cant borrow this book", messageStyle: .Error).show()
                return
            }
            
            /* Borrow book if only one user is in possession of the book */
            if otherUsers.count == 1 {
                self.borrowBookFromUser(owners.first!._id!)
                return
            }
            
            /* Present a list of all users in possession of the book */
            self.showListWithItems(otherUsers, andCompletionHandler: { (selectedOwners) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                
                if selectedOwners.isEmpty {
                    csprint(CS_DEBUG_BOOK_VIEW, "Canceled borrow book:", self.bookInformation)
                    return
                }
                
                let owner = selectedOwners.first as! User
                self.borrowBookFromUser(owner._id!)
            })
        }
        Analytics.addEvent("BorrowBook")
    }
    
    private func borrowBookFromUser(userID: String) {
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Borrowing book..", inView: self.view)
        
        DataHandler.addRenter(User.localUser!._id!, toTitle: self.bookInformation!.isbn!, withOwner: userID, withCompletionHandler: { (isSuccess) -> Void in
            activityIndicatorView.stop()
            
            let message = isSuccess ? "Sucessfully borrowed book" : "Failed to borrow book"
            csprint(CS_DEBUG_BOOK_VIEW, message, self.bookInformation)
            MessagePopupView(message: message, messageStyle: isSuccess ? .Success : .Error).show()
        })
    }
    
    func returnBook() {
        csprint(CS_DEBUG_BOOK_VIEW, "Returning book:", self.bookInformation)
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Collecting information", inView: self.view)
        
        DataHandler.ownersOfBooksWithParameters(["isbn":self.bookInformation!.isbn!, "rentedTo": User.localUser!._id!]) { (owners) -> Void in
            activityIndicatorView.stop()
            
            /* Abort is no users are in possession of the book */
            if owners.count == 0 {
                MessagePopupView(message: "You are not borrowing this book", messageStyle: .Error).show()
                return
            }
            
            /* Borrow book if only one user is in possession of the book */
            if owners.count == 1 {
                self.returnBookToUser(owners.first!._id!)
                return
            }
            
            /* Present a list of all users in possession of the book */
            self.showListWithItems(owners, andCompletionHandler: { (selectedOwners) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
                
                if selectedOwners.isEmpty {
                    csprint(CS_DEBUG_BOOK_VIEW, "Canceled borrow book:", self.bookInformation)
                    return
                }
                
                let owner = selectedOwners.first as! User
                self.returnBookToUser(owner._id!)
            })
        }
        Analytics.addEvent("ReturnBook")
    }
    
    private func returnBookToUser(userID: String) {
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Returning book..", inView: self.view)
        
        DataHandler.removeRenter(User.localUser!._id!, fromTitle: self.bookInformation!.isbn!, withOwner: userID) { (isSuccess) -> Void in
            activityIndicatorView.stop()
            
            let message = isSuccess ? "Sucessfully returned book" : "Failed to return book"
            csprint(CS_DEBUG_BOOK_VIEW, message, self.bookInformation)
            MessagePopupView(message: message, messageStyle: isSuccess ? .Success : .Error).show()
        }
    }
    
//    MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBookInformation" {
            let bookInformationVC = segue.destinationViewController as! BookInformationViewController
            bookInformationVC.bookInformation = self.bookInformation
        }
    }
}