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
    
    @IBOutlet weak var coverImageView: UIImageView?
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var bookView: UIView!
    
    @IBOutlet var buttons: [UIButton]?
    
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
        
        self.messageLabel.hidden = true;
        self.messageLabel.layer.cornerRadius = 6;
        self.messageLabel.layer.masksToBounds = true;
        
        self.activityIndicator.stopAnimating()
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
                button.enabled = User.localUser != nil
            }
        }
        
    }
    
    func fadeView(view: UIView, fadeIn: Bool, completionHandler: ((Bool)->Void)?) {
        view.alpha = fadeIn ? 0 : 1
        view.hidden = false
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            view.alpha = fadeIn ? 1 : 0
            }) { (finished) -> Void in
                view.hidden = !fadeIn
                completionHandler?(finished)
        }
    }
    
    private func showMessage(message: String, error: Bool) {
        self.messageLabel.text = message
        self.messageLabel.backgroundColor = UIColor(red: error ? 0.8 : 0, green: error ? 0 : 0.8, blue: 0, alpha: 0.7)
        
        self.fadeView(self.messageLabel, fadeIn: true, completionHandler: { (_) -> Void in
            Utilities.delayDispatchInQueue(dispatch_get_main_queue(), delay: 1, block: { () -> Void in
                self.fadeView(self.messageLabel, fadeIn: false, completionHandler: nil)
            })
        })
    }
    
    @IBAction func addBookToShelf(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Adding book:", self.book)

        self.book!.owner = User.localUser!._id
        
        self.activityIndicator.startAnimating()
        DataHandler.addBook(self.book!) { (isSuccess) -> Void in
            self.activityIndicator.stopAnimating()
            self.showMessage("Successfully added book", error: !isSuccess)
            
            if isSuccess {
                csprint(CS_DEBUG_BOOK_VIEW, "Successfully added book:", self.book)
            } else {
                csprint(CS_DEBUG_BOOK_VIEW, "Failed to add book:", self.book)
            }
            
            self.updateView()
        }
        
        Analytics.addEvent("BookAdded")
         

        
    }
    
    @IBAction func removeBookFromShelf(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Removing book:", self.book)
        
        self.activityIndicator.startAnimating()
        DataHandler.removeBook(self.book!._id) { (isSuccess) -> Void in
            
            self.showMessage("Successfully removed book", error: !isSuccess)
            self.activityIndicator.stopAnimating()
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
    
    @IBAction func borrow(sender: AnyObject) {
        
    }
//    MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBookInformation" {
            let bookInformationVC = segue.destinationViewController as! BookInformationViewController
            bookInformationVC.bookInformation = self.book?.details
        }
    }
}