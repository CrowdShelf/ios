//
//  SearchViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 26/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView?

    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    let tableViewDataSource: TableViewArrayDataSource
    var tableViewDelegate: TableViewSelectionDelegate?
    
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
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        
        tableView?.registerCellForClass(ListTableViewCell)
//        tableView?.tableHeaderView = searchController.searchBar
        tableView?.dataSource = tableViewDataSource
        tableView?.delegate = tableViewDelegate
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if (searchController.searchBar.text ?? "") == "" {
            return
        }
        
        debouncedSearchRequest?()
    }
    
    func sendRequest() {
        DataHandler.resultsForQuery(searchController.searchBar.text!) { (bookInformation) -> Void in
            self.tableViewDataSource.items = bookInformation.filter {$0.isbn != ""}
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView?.reloadData()
            })
        }
    }
}
