//
//  CSShelfViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import RealmSwift

enum CSShelfViewState: Int {
    case OwnedBooks    = 0
    case BorrowedBooks = 1
}

class CSShelfViewController: CSBaseViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var stateControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView?
    
    var books : [CSBook] = []
    
    var ownedBooks: [CSBook] {
        return CSUser.localUser != nil ? self.books.filter({$0.owner == CSUser.localUser!._id}) : []
    }
    var borrowedBooks: [CSBook] {
        return CSUser.localUser != nil ? self.books.filter({$0.owner != CSUser.localUser!._id}) : []
    }
    
    var state: CSShelfViewState {
        return CSShelfViewState(rawValue: self.stateControl.selectedSegmentIndex)!
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadBooks", name: CSNotification.LocalUserUpdated, object: nil)
        
        self.loadBooks()
    }
    
    func loadBooks() {
//        Use server by uncommenting this section
        CSDataHandler.getBooksWithParameters(nil) { (books) -> Void in
            self.books = books
            self.updateView()
            
            for book in books {
                CSDataHandler.informationAboutBook(book.isbn, withCompletionHandler: { (bookInformation) -> Void in
                    book.details = bookInformation.first
                    self.updateView()
                })
            }
        }
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
        return (self.state == .OwnedBooks ? self.ownedBooks : self.borrowedBooks).count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BookCell", forIndexPath: indexPath) as! CSBookCollectionViewCell
        cell.book = (self.state == .OwnedBooks ? self.ownedBooks : self.borrowedBooks)[indexPath.row]
        return cell
    }
    
//    MARK: - Actions
    
    
    @IBAction func stateChanged(sender: AnyObject) {
        self.updateView()
    }
    
//    MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowBook" {
            let navigationVC = segue.destinationViewController as! UINavigationController
            let bookVC = navigationVC.viewControllers.first as! CSBookViewController
            bookVC.book = (sender as! CSBookCollectionViewCell).book
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}