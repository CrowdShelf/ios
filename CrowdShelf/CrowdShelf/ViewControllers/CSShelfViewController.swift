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
    
    override func viewDidLoad() {
        addTestDataIfNecessary()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.books = CSLocalDataHandler.books()
        self.collectionView?.reloadData()
    }
    
    private func addTestDataIfNecessary() {
        if CSLocalDataHandler.books().count == 0 {
            self.books = [
                CSBook(isbn: "0735619670"),
                CSBook(isbn: "9780471145943"),
                CSBook(isbn: "9781133603627"),
                CSBook(isbn: "9780130920713"),
                CSBook(isbn: "9781292100241"),
                CSBook(isbn: "9780566089237"),
            ]
            
            for book in books {
                CSLocalDataHandler.setBook(book)
            }
        }
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
}