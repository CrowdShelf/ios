//
//  CSListViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 01/09/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

@objc protocol Listable {
    var title : String {get}
    optional var subtitle: String {get}
    optional var image : UIImage? {get}
}

class SelectionViewController: BaseViewController, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var tableViewCellStyle: UITableViewCellStyle = .Subtitle
    
    var multipleSelection: Bool = false
    
    var completionHandler: (([Listable])->Void)?
    
    lazy var tableViewDataSource: TableViewArrayDataSource = { [unowned self] in
        return TableViewArrayDataSource(cellReuseIdentifier: "ListCell") { (cell, item) -> Void in
            (cell as! ListTableViewCell).listable = item as? Listable
        }
    }()
    
    var listData : [Listable] {
        set {
            self.tableViewDataSource.items = newValue
            self.tableView?.reloadData()
        }
        get {
            return self.tableViewDataSource.items as? [Listable] ?? []
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self.tableViewDataSource
        
        assert(self.tableView != nil, "Table view was not set for ListViewController")
        
        self.doneButton.enabled = self.multipleSelection
    }
    
    func updateView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView?.reloadData()
        })
    }
    
    
//    MARK: - Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !self.multipleSelection {
            self.completionHandler?([self.listData[indexPath.row]])
        }
    }
    
//    MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        self.completionHandler?([])
    }
    
    @IBAction func done(sender: AnyObject) {
        let selectedItems = self.tableView!.indexPathsForSelectedRows!.map({self.listData[$0.row]})
        completionHandler?(selectedItems)
    }
    
    
    
}