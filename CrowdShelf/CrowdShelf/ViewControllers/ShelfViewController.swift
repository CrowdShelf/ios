//
//  ShelfViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import RealmSwift

class ShelfViewController: BaseViewController, UITableViewDataSource, ShelfTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView?
    
    var shelves : [Shelf] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadShelves", name: Notification.LocalUserUpdated, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadShelves()
    }
    
    func loadShelves() {
        if User.localUser == nil {
            return
        }
        
        let ownedShelf = Shelf(name: "Owned books", parameters: ["owner": User.localUser!._id]) {User.localUser != nil && $0.owner == User.localUser!._id}
        
        let borrowedShelf = Shelf(name: "Lent books", parameters: ["rentedTo": User.localUser!._id]) {User.localUser != nil && $0.rentedTo == User.localUser!._id}
        
        let lentShelf = Shelf(name: "Lent books", parameters: ["owner": User.localUser!._id]) {User.localUser != nil && $0.rentedTo != "" && $0.owner == User.localUser!._id}
        
        self.shelves = [ownedShelf, borrowedShelf, lentShelf]
        
        self.shelves.enumerate().forEach {loadShelf($0.index)}
    }
    
    private func loadShelf(shelfIndex: Int) {
//        TODO: Filter before retrieving information
        var shelf = self.shelves[shelfIndex] 
        
        DataHandler.getBooksWithParameters(shelf.parameters) { (books) -> Void in
            var booksUpdated = 0
            for book in books {
                DataHandler.informationAboutBook(book.isbn, withCompletionHandler: { (information) -> Void in
                    
                    Realm.write { realm -> Void in
                        book.details = information.first
                    }
                    
                    booksUpdated++
                    
                    if booksUpdated == books.count {
                        shelf.books = books.filter(shelf.filter)
                        self.updateView()
                    }
                })
            }
        }
    }
    
    func updateView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView?.reloadData()
        })
    }

//    MARK: - Table View Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shelves.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShelfCell") as! ShelfTableViewCell
        cell.delegate = self
        
        cell.shelf = self.shelves[indexPath.row]

        return cell
    }
    
//    MARK: - Shelf Table View Cell Delegate
    
    func showAllBooksForShelfTableViewCell(shelfTableViewCell: ShelfTableViewCell) {
        self.performSegueWithIdentifier("ShowAllBooks", sender: shelfTableViewCell)
    }
    
    func shelfTableViewCell(shelfTableViewCell: ShelfTableViewCell, didSelectBook book: Book) {
        self.performSegueWithIdentifier("ShowBook", sender: book)
    }
    
    
    @IBAction func logOut(sender: AnyObject) {
        LocalDataHandler.setObject(nil, forKey: "user", inFile: LocalDataFile.User)
        User.localUser = nil
    }
    
//    MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "ShowAllBooks" {
            let booksVC = segue.destinationViewController as! BookCollectionViewController
            booksVC.shelf = (sender as! ShelfTableViewCell).shelf
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}