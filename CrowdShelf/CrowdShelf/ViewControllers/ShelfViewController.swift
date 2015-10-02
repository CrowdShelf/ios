//
//  ShelfViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import RealmSwift

enum ShelfType: String {
    case Owned      = "My books"
    case Borrowed   = "Borrowed books"
    case Lent       = "Lent books"
    
    static let allValues: [ShelfType] = [.Owned, .Borrowed, .Lent]
    
    func parameters() -> [String: AnyObject]? {
        switch self {
        case .Owned:
            return ["owner": User.localUser!._id]
        case .Borrowed:
            return ["rentedTo": User.localUser!._id]
        case .Lent:
            return ["owner": User.localUser!._id]
        }
    }
    
    func filter() -> ((Book) -> Bool) {
        switch self {
        case .Owned:
            return {$0.owner == User.localUser!._id}
        case .Borrowed:
            return {$0.rentedTo == User.localUser!._id}
        case .Lent:
            return {$0.rentedTo != "" && $0.owner == User.localUser!._id}
        }
    }
}

class ShelfViewController: BaseViewController, UITableViewDataSource, ShelfTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView?
    
    var shelves : [ShelfType: Shelf] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadShelves", name: Notification.LocalUserUpdated, object: nil)
        
        ShelfType.allValues.forEach {
            self.shelves[$0] = Shelf(type: $0)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadShelves()
    }
    
    func loadShelves() {
        if User.localUser == nil {
            return
        }
        
        ShelfType.allValues.forEach { self.loadShelf($0) }
    }
    
    private func loadShelf(shelf: ShelfType) {
//        TODO: Filter before retrieving information
        DataHandler.getBooksWithParameters(shelf.parameters()) { (books) -> Void in
            var booksUpdated = 0
            for book in books {
                DataHandler.informationAboutBook(book.isbn, withCompletionHandler: { (information) -> Void in
                    
                    Realm.write { realm -> Void in
                        book.details = information.first
                    }
                    
                    booksUpdated++
                    
                    if booksUpdated == books.count {
                        self.shelves[shelf]?.books = books.filter(shelf.filter())
                        self.updateView()
                    }
                })
            }
        }
    }
    
    private func filterBooks(books: [Book], forShelf shelf: ShelfType) -> [Book] {
        switch shelf {
        case .Lent:
            return books.filter {$0.rentedTo != ""}
        default:
            return books
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
        
        let shelf = ShelfType.allValues[indexPath.row]
        cell.shelf = self.shelves[shelf]
        
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