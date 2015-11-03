//
//  ShelfViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 28/08/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import RealmSwift

class ShelfViewController: BaseViewController, ShelfTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView?
    
    let refreshControl = UIRefreshControl()
    var tableViewDataSource: TableViewArrayDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewDataSource = TableViewArrayDataSource(cellReuseIdentifier: "ShelfCell") { (cell, item, _) -> Void in
            let shelfCell = cell as! ShelfTableViewCell
            shelfCell.shelf = item as? Shelf
            shelfCell.delegate = self           // FIXME: Bad way to detect book selection in cell

        }
        self.tableView?.dataSource = self.tableViewDataSource
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadShelves", name: Notification.LocalUserUpdated, object: nil)
        
        refreshControl.addTarget(self, action: "loadShelves", forControlEvents: .ValueChanged)
        tableView?.addSubview(refreshControl)
        loadShelves()
    }
    
    func loadShelves() {
        var shelves: [Shelf] = []
        
        if User.localUser != nil {
            let ownedShelf = Shelf(name: "Owned books", parameters: ["owner": User.localUser!._id!]) {User.localUser != nil && $0.owner! == User.localUser!._id!}
            let borrowedShelf = Shelf(name: "Borrowed books", parameters: ["rentedTo": User.localUser!._id!]) {User.localUser != nil && $0.rentedTo! == User.localUser!._id!}
            let lentShelf = Shelf(name: "Lent books", parameters: ["owner": User.localUser!._id!]) {User.localUser != nil && $0.rentedTo != nil && $0.owner! == User.localUser!._id!}
            
            
            shelves = [ownedShelf, borrowedShelf, lentShelf]
        }
        
        self.tableViewDataSource?.items = shelves
        
        self.tableViewDataSource?.items.enumerate().forEach {
            loadShelf($0.index)
        }
    }
    
    private func loadShelf(shelfIndex: Int) {
        let shelf = self.tableViewDataSource!.items[shelfIndex] as! Shelf
        
        
        DataHandler.getBooksWithInformationWithParameters(shelf.parameters) { (books) -> Void in
            shelf.books = books.filter(shelf.filter)
            self.refreshControl.endRefreshing()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateView()
            })
        }
    }
    
    func updateView() {
        self.tableView?.reloadData()
    }
    
//    MARK: - Shelf Table View Cell Delegate
    
//    TODO: This shouldnt be here
    func showAllBooksForShelfTableViewCell(shelfTableViewCell: ShelfTableViewCell) {
        self.performSegueWithIdentifier("ShowAllBooks", sender: shelfTableViewCell)
    }
    
    func shelfTableViewCell(shelfTableViewCell: ShelfTableViewCell, didSelectTitle title: BookInformation) {
        self.performSegueWithIdentifier("ShowBook", sender: title)
    }
    
//    MARK: - Actions
    
//    TODO: Extract logout functionality
    @IBAction func logOut(sender: AnyObject) {
        KeyValueHandler.setObject(nil, forKey: "user", inFile: LocalDataFile.User)
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