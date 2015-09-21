//
//  CSShelfViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class CSShelfViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    var books : [CSBook] = []

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadBooks", name: CSNotification.LocalUserUpdated, object: nil)
        
        self.loadBooks()
    }
    
    func loadBooks() {
        
        let value = [
            "isbn": "9780262533058",
            "owner": "oyvindkg",
        ]
        
        self.books = [CSBook(value: value)]
        for book in books {
            CSDataHandler.informationAboutBook(book.isbn, withCompletionHandler: { (bookInformation) -> Void in
                book.details = bookInformation
                self.updateView()
            })
        }
        
//        Use server by oncommenting this section
//        CSDataHandler.getBooksWithCompletionHandler { (books) -> Void in
//            self.books = books
//            self.updateView()
//            
//            for book in books {
//                CSDataHandler.informationAboutBook(book.isbn, withCompletionHandler: { (bookInformation) -> Void in
//                    book.details = bookInformation
//                    self.updateView()
//                })
//            }
//        }
    }
    
    func updateView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView?.reloadData()
        })
        
    }

//    MARK: - Collection View Cell Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.books.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BookCell", forIndexPath: indexPath) as! CSBookCollectionViewCell
        cell.book = self.books[indexPath.row]
        return cell
    }
    
//    MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBook" {
            let bookVC = segue.destinationViewController as! CSBookViewController
            bookVC.book = (sender as! CSBookCollectionViewCell).book
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}