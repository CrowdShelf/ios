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
        self.books = CSLocalDataHandler.shelf()
        
        addTestDataIfNecessary()
        
        self.collectionView?.reloadData()
    }
    
    private func addTestDataIfNecessary() {
        if self.books.count == 0 {
            self.books = [
                CSBook(isbn: "0735619670", numberOfCopies: Int(arc4random_uniform(5))),
                CSBook(isbn: "9780471145943", numberOfCopies: Int(arc4random_uniform(5))),
                CSBook(isbn: "9781133603627", numberOfCopies: Int(arc4random_uniform(5))),
                CSBook(isbn: "9780130920713", numberOfCopies: Int(arc4random_uniform(5))),
                CSBook(isbn: "9781292100241", numberOfCopies: Int(arc4random_uniform(5))),
                CSBook(isbn: "9780566089237", numberOfCopies: Int(arc4random_uniform(5))),
            ]
            
            for book in books {
                CSLocalDataHandler.addBookToShelf(book)
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
    
//    MARK: - Actions
    
    @IBAction func showScanner(sender: AnyObject) {
        let pageViewController = self.parentViewController as! UIPageViewController
        let scannerVC = pageViewController.dataSource!.pageViewController(pageViewController, viewControllerAfterViewController: self)!
        
        pageViewController.setViewControllers([scannerVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true) { (complete) -> Void in
            
        }
    }
    
}