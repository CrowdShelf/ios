//
//  TableViewSelectionDelegate.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class TableViewSelectionDelegate: NSObject, UITableViewDelegate {
    typealias SelectionHandler = ((tableView: UITableView, indexPath: NSIndexPath, selected: Bool) -> Void)
    
    var selectionHandler: SelectionHandler
    var headerHeight: CGFloat = 1.0
    
    init(selectionHandler: SelectionHandler) {
        self.selectionHandler = selectionHandler
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectionHandler(tableView: tableView, indexPath: indexPath, selected: true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectionHandler(tableView: tableView, indexPath: indexPath, selected: false)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
}