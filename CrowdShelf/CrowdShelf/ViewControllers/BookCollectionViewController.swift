//
//  BookCollectionView.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 29/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class BookCollectionViewController: CollectionViewController {
    
    var shelf: Shelf? {
        didSet {
            self.collectionData = shelf?.books ?? []
            self.updateView()
        }
    }

    override func viewWillAppear(animated: Bool) {
        collectionView?.alwaysBounceVertical = false
        
        super.viewWillAppear(animated)
        
        updateContent()
    }
    
    override func updateContent() {
        super.updateContent()
        
        DataHandler.getBooksWithParameters(self.shelf?.parameters) { (books) -> Void in
            self.shelf?.books = books.filter(self.shelf!.filter)
            self.updateView()
            
            for book in self.collectionData as! [Book] {
                DataHandler.informationAboutBook(book.isbn!, withCompletionHandler: { (information) -> Void in
                                        
                    book.details = information.first
                    
                    self.updateView()
                })
            }
            
            self.refreshControl.endRefreshing()
        }
    }

    override func updateView() {
        super.updateView()
        self.title = self.shelf?.name
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let book = self.collectionData[indexPath.row] as? Book
        self.performSegueWithIdentifier("ShowBook", sender: book?.details)
    }
    
    override func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}