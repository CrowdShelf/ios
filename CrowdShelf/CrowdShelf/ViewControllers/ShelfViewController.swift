//
//  ShelfViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import RealmSwift

enum ShelfViewState: Int {
    case OwnedBooks    = 0
    case BorrowedBooks = 1
}

class ShelfViewController: BaseViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var stateControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView?
    
    var books : [Book] = []
    
    var ownedBooks: [Book] {
        return User.localUser != nil ? self.books.filter({$0.owner == User.localUser!._id}) : []
    }
    var allBooks: [Book] {
        return self.books
    }
    
    var state: ShelfViewState {
        return ShelfViewState(rawValue: self.stateControl.selectedSegmentIndex)!
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadBooks", name: Notification.LocalUserUpdated, object: nil)
        
        self.loadBooks()
    }
    
    func loadBooks() {
//        Use server by uncommenting this section
        DataHandler.getBooksWithParameters(nil) { (books) -> Void in
            self.books = books
            self.updateView()
            
            for book in books {
                DataHandler.informationAboutBook(book.isbn, withCompletionHandler: { (bookInformation) -> Void in
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
        return (self.state == .OwnedBooks ? self.ownedBooks : self.allBooks).count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BookCell", forIndexPath: indexPath) as! BookCollectionViewCell
        cell.book = (self.state == .OwnedBooks ? self.ownedBooks : self.allBooks)[indexPath.row]
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
            let bookVC = navigationVC.viewControllers.first as! BookViewController
            bookVC.book = (sender as! BookCollectionViewCell).book
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}