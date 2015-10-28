//
//  ListViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 16/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


protocol ListViewControllerDelegate {
    func listViewController(listViewController: ListViewController, performActionForIndexPath indexPath: NSIndexPath)
}

@objc protocol ListViewControllerDataSource {
    optional func listViewController(listViewController: ListViewController, accessoryTypeForIndexPath indexPath: NSIndexPath) -> UITableViewCellAccessoryType
    optional func listViewController(listViewController: ListViewController, shouldShowSubtitleForCellAtIndexPath indexPath: NSIndexPath) -> Bool
}

class ListViewController: BaseViewController {
    
    @IBOutlet var tableView: UITableView?
    
    var delegate: ListViewControllerDelegate?
    var dataSource: ListViewControllerDataSource?
    
    lazy var tableViewDataSource: TableViewArrayDataSource = {
        return TableViewArrayDataSource(cellReuseIdentifier: ListTableViewCell.cellReuseIdentifier) { (cell, item, indexPath) -> Void in
            
            let listCell = cell as? ListTableViewCell
            listCell?.listable = item as? Listable
            
            listCell?.configureForButtonStyle((item as? Button)?.buttonStyle ?? .None)
            
            listCell?.accessoryType = self.dataSource?.listViewController?(self, accessoryTypeForIndexPath: indexPath) ?? .None
            listCell?.showSubtitle = self.dataSource?.listViewController?(self, shouldShowSubtitleForCellAtIndexPath: indexPath) ?? false
        }
    }()
    
    lazy var tableViewDelegate: TableViewSelectionDelegate = {
        return TableViewSelectionDelegate { (_, indexPath, selected) -> Void in
            if selected {
                self.delegate?.listViewController(self, performActionForIndexPath: indexPath)
            }
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView!.registerCellForClass(ListTableViewCell)
        
        tableView!.dataSource = tableViewDataSource
        tableView!.delegate = tableViewDelegate
        
        tableView!.reloadData()
    }
}