//
//  SearchViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, UISearchResultsUpdating {
    
    enum SearchFilter: Int {
        case All, Crowds
    }
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var noResultsLabel: UILabel?
    
    let searchController: UISearchController = UISearchController(searchResultsController: nil)

    let tableViewDataSource: TableViewArrayDataSource
    var tableViewDelegate: TableViewSelectionDelegate?
    
    var ISBNsInCrowds: Set<String>?
    var filter: SearchFilter = .All
    var debouncedSearchRequest: (()->())?
    
    required init?(coder aDecoder: NSCoder) {
        
        tableViewDataSource = TableViewArrayDataSource(cellReuseIdentifier: ListTableViewCell.cellReuseIdentifier, cellConfigurationHandler: { (cell, item, indexPath) -> Void in
            let listCell = cell as! ListTableViewCell
            listCell.listable = (item as! Listable)
            listCell.iconImageView?.viewStyle = .Square
            listCell.iconImageView?.contentMode = .ScaleAspectFit
        })
        
        super.init(coder: aDecoder)
        
        tableViewDelegate = TableViewSelectionDelegate(selectionHandler: { (tableView, indexPath, selected) -> Void in
            if selected {
                self.performSegueWithIdentifier("ShowBook", sender: self.tableViewDataSource.itemForIndexPath(indexPath))
            }
        })
        
        debouncedSearchRequest = Utilities.debounce(0.5, action: self.sendRequest)
    }
    
    override func viewDidLoad() {
        definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        
        tableView?.registerCellForClass(ListTableViewCell)
        tableView?.dataSource = tableViewDataSource
        tableView?.delegate = tableViewDelegate
        
        DataHandler.getBooksInCrowdsForUser(User.localUser!._id!, withCompletionHandler: { (books) -> Void in
            self.ISBNsInCrowds = Set(books.map {$0.isbn!})
            
            if self.filter == .Crowds {
                self.tableViewDataSource.items = self.tableViewDataSource.items.filter { self.ISBNsInCrowds!.contains($0.isbn!!) }
            }
            
            self.updateView()
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if (searchController.searchBar.text ?? "") == "" {
            return
        }
        
        debouncedSearchRequest?()
    }
    
    func sendRequest() {
        Analytics.addEventWithSearchProperties("BookSearch", search: self.searchController.searchBar.text!)
        
        DataHandler.resultsForQuery(searchController.searchBar.text!) { (bookInformation) -> Void in
            self.tableViewDataSource.items = bookInformation.filter {$0.isbn != ""}
            
            if self.filter != .All {
                self.tableViewDataSource.items = self.tableViewDataSource.items.filter { self.ISBNsInCrowds!.contains($0.isbn!!) }
            }
            
            self.updateView()
        }
    }
    
    func updateView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.noResultsLabel?.hidden = !self.tableViewDataSource.items.isEmpty
            self.tableView?.reloadData()
        })
    }
    
    
    @IBAction func filterChanged(sender: UISegmentedControl) {
        Analytics.addEvent("SwitchedFilter")
        filter = SearchFilter(rawValue: sender.selectedSegmentIndex)!
        debouncedSearchRequest?()
    }
}
