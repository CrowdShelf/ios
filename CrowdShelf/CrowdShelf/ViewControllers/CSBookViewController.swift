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
    
    
//    MARK: - Properties
    
    var book : CSBook? {
        didSet {
            self.updateView()
            
            if book?.details == nil {
                CSDataHandler.detailsForBook(book!.isbn, withCompletionHandler: { (details) -> Void in
                    self.book?.details = details
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
    }
    
    func updateView() {
        
        if self.book?.details?.authors != nil {
            self.authorsLabel?.text = ", ".join(self.book!.details!.authors)
        }
        
        if self.book != nil {
            self.numberOfCopiesLabel?.text = "\(self.book!.numberOfCopies)"
        }
        
        self.coverImageView?.image = self.book?.details?.thumbnailImage
        self.titleLabel?.text = self.book?.details?.title
        self.publisherLabel?.text = self.book?.details?.publisher
        self.descriptionTextView?.text = self.book?.details?.description
    }
    
    @IBAction func addBookToShelf(sender: AnyObject) {
        self.book?.numberOfCopies++

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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}