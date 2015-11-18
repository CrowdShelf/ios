//
//  BookCollectionView.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 29/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class ShelfCollectionViewController: CollectionViewController {
    
    var shelf: Shelf? {
        didSet {
            self.collectionData = shelf?.titles ?? []
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
        
        DataHandler.getBooksWithParameters(self.shelf?.parameters) { (books, dataSource) -> Void in
            self.shelf?.books = books.filter(self.shelf!.filter)
            
            for bookInformation in self.collectionData as! [BookInformation] {
                DataHandler.informationAboutBook(bookInformation.isbn!, withCompletionHandler: { (information) -> Void in
                                        
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.updateView()
                    })
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateView()
                self.refreshControl.endRefreshing()
            })
        }
    }

    override func updateView() {
        super.updateView()
        self.title = self.shelf?.name
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let bookInformation = self.collectionData[indexPath.row] as? BookInformation
        self.performSegueWithIdentifier("ShowBook", sender: bookInformation)
    }
    
    override func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}