//
//  CSBookViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class CSBookViewController: UIViewController {
    
//    MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var authorsLabel: UILabel?
    @IBOutlet weak var publisherLabel: UILabel?
    
    @IBOutlet weak var coverImageView: UIImageView?
    
    @IBOutlet weak var descriptionTextView: UITextView?
    
    @IBOutlet var buttons: [UIButton]?
    
//    MARK: - Properties
    
    var book : CSBook? {
        didSet {
            self.updateView()
            
            if book?.details == nil {
                CSDataHandler.informationAboutBook(book!.isbn, withCompletionHandler: { (information) -> Void in
                    self.book?.details = information
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
    }
    
    func updateView() {
        
        self.coverImageView?.image = self.book?.details?.thumbnail
        self.titleLabel?.text = self.book?.details?.title
        self.publisherLabel?.text = self.book?.details?.publisher
        self.descriptionTextView?.text = self.book?.details?.summary
        
        
        if self.book?.details != nil {
            self.authorsLabel?.text = self.book?.details?.authors.map {($0 as! RLMWrapper).stringValue!}.joinWithSeparator(", ")
        }
        
        if self.buttons != nil {
            for button in self.buttons! {
                button.enabled = CSUser.localUser != nil
            }
        }
        
    }
    
    @IBAction func addBookToShelf(sender: AnyObject) {
        csprint(CS_DEBUG_BOOK_VIEW, "Adding book:", self.book)
        
        self.book!.owner = CSUser.localUser!.username
        CSDataHandler.addBook(self.book!) { (isSuccess) -> Void in
            if isSuccess {
                csprint(CS_DEBUG_BOOK_VIEW, "Successfully added book:", self.book)
            } else {
                csprint(CS_DEBUG_BOOK_VIEW, "Failed to add book:", self.book)
            }
            
            self.updateView()
        }
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
        
        self.updateView()
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}