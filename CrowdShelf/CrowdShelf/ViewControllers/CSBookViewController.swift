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
    @IBOutlet weak var numberOfCopiesLabel: UILabel?
    
    @IBOutlet weak var coverImageView: UIImageView?
    
    @IBOutlet weak var descriptionTextView: UITextView?
    
    @IBOutlet var buttons: [UIButton]?
    
//    MARK: - Properties
    
    var book : CSBook? {
        didSet {
            self.updateView()
            
            if book?.details == nil {
                CSDataHandler.informationForBook(book!.isbn, withCompletionHandler: { (information) -> Void in
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
        
        self.coverImageView?.image = self.book?.details?.thumbnailImage
        self.titleLabel?.text = self.book?.details?.title
        self.publisherLabel?.text = self.book?.details?.publisher
        self.descriptionTextView?.text = self.book?.details?.description
        
        
        if self.book?.details?.authors != nil {
            self.authorsLabel?.text = self.book!.details!.authors.joinWithSeparator(", ")
        }
        
        if self.book != nil {
            self.numberOfCopiesLabel?.text = "\(self.book!.numberOfCopies)"
        }
        
        if self.buttons != nil {
            for button in self.buttons! {
                button.enabled = CSUser.localUser != nil
            }
        }
        
    }
    
    @IBAction func addBookToShelf(sender: AnyObject) {
        self.book?.numberOfCopies++
        
        
        if !CSUser.localUser!.books.contains(self.book!) {
            CSUser.localUser?.booksOwned.append(self.book!)
        }

        self.updateView()
    }
    
    @IBAction func removeBookFromShelf(sender: AnyObject) {
        if self.book!.numberOfCopies <= 0 {
            return
        }
        
        self.book?.numberOfCopies--

        self.updateView()
    }
    
    @IBAction func close(sender: AnyObject) {
        if self.book?.owner != nil {
            CSDataHandler.addBook(self.book!, withCompletionHandler: { (success) -> Void in
                
            })
        }
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}