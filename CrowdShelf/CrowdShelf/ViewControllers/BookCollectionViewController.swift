//
//  BookCollectionView.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 29/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import RealmSwift

class BookCollectionViewController: CollectionViewController {
    
    var shelf: Shelf? {
        didSet {
            self.collectionData = shelf?.books ?? []
            self.updateView()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        DataHandler.getBooksWithParameters(self.shelf?.parameters) { (books) -> Void in
            self.shelf?.books = books.filter(self.shelf!.filter)
            
            for book in self.collectionData as! [Book] {
                DataHandler.informationAboutBook(book.isbn, withCompletionHandler: { (information) -> Void in
                    Realm.write { realm -> Void in
                        book.details = information.first
                    }
                    
                    self.updateView()
                })
            }
            
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowBook", sender: self.collectionData[indexPath.row])
    }
    
    override func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}