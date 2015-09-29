//
//  ShelfViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import RealmSwift

enum ShelfType: Int {
    case Owned    = 1
    case Borrowed
    case Lent
}

class ShelfViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var ownedBooksCollectionView: UICollectionView!
    @IBOutlet weak var borrowedBooksCollectionView: UICollectionView!
    @IBOutlet weak var lentBooksCollectionView: UICollectionView!
    
    @IBOutlet weak var showAllLentBooksButton: UIButton!
    @IBOutlet weak var showAllBorrowedBooksButton: UIButton!
    @IBOutlet weak var showAllOwnedBooksButton: UIButton!
    
    @IBOutlet var collectionViews: [UICollectionView]!
    
    var books : [Book] = []
    
    var ownedBooks: [Book] {
        return User.localUser != nil ? self.books.filter({$0.owner == User.localUser!._id}) : []
    }
    var borrowedBooks: [Book] {
        return User.localUser != nil ? self.books.filter({$0.rentedTo == User.localUser!._id}) : []
    }
    var lentBooks: [Book] {
        return User.localUser != nil ? self.books.filter({$0.owner == User.localUser!._id && $0.rentedTo != ""}) : []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ownedBooksCollectionView.tag = ShelfType.Owned.rawValue
        self.borrowedBooksCollectionView.tag = ShelfType.Borrowed.rawValue
        self.lentBooksCollectionView.tag = ShelfType.Lent.rawValue
        
        self.showAllOwnedBooksButton.tag = ShelfType.Owned.rawValue
        self.showAllBorrowedBooksButton.tag = ShelfType.Borrowed.rawValue
        self.showAllLentBooksButton.tag = ShelfType.Lent.rawValue
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadBooks", name: Notification.LocalUserUpdated, object: nil)
        
        self.loadBooks()
    }
    
    func loadBooks() {
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Loading books..", inView: self.view)
        DataHandler.getBooksWithParameters(nil) { (books) -> Void in
            self.books = books
            self.updateView()
            
            for book in books {
                DataHandler.informationAboutBook(book.isbn, withCompletionHandler: { (bookInformation) -> Void in
                    activityIndicatorView.stop()
                    book.details = bookInformation.first
                    self.updateView()
                })
            }
        }
    }
    
    func updateView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionViews.forEach {$0.reloadData()}
        })
    }

//    MARK: - Collection View Cell Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.booksForShelf(collectionView.tag).count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BookCell", forIndexPath: indexPath) as! CollectableCell
        cell.collectable = self.booksForShelf(collectionView.tag)[indexPath.row]
        return cell
    }
    
    private func booksForShelf(shelfTag: Int) -> [Book] {
        switch ShelfType(rawValue: shelfTag)! {
        case .Owned:
            return self.ownedBooks
        case .Borrowed:
            return self.borrowedBooks
        case .Lent:
            return self.lentBooks
        }
    }
    
//    MARK: Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowBook", sender: self.booksForShelf(collectionView.tag)[indexPath.row])
    }
    
//    MARK: - Actions
    
    @IBAction func stateChanged(sender: AnyObject) {
        self.updateView()
    }
    
    @IBAction func showAllBooks(sender: UIButton) {
        self.performSegueWithIdentifier("ShowAllBooks", sender: sender)
    }
    
//    MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "ShowAllBooks" {
            let booksVC = segue.destinationViewController as! BookCollectionViewController
            
            booksVC.collectionData = self.booksForShelf(sender!.tag)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}