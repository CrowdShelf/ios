//
//  TableViewArrayDataSource.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 13/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class TableViewArrayDataSource: NSObject, UITableViewDataSource {
    
    typealias CellConfigurationHandler = ((cell: UITableViewCell, item: AnyObject) -> Void)
    
    var items: [AnyObject]
    var cellReuseIdentifier: String
    var cellConfigurationHandler: CellConfigurationHandler
    
    init(items: [AnyObject] = [], cellReuseIdentifier: String, cellConfigurationHandler: CellConfigurationHandler) {
        self.items = items
        self.cellReuseIdentifier = cellReuseIdentifier
        self.cellConfigurationHandler = cellConfigurationHandler
    }
    
    func itemForIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if let sections = items as? [[AnyObject]] {
            return sections[indexPath.section][indexPath.row]
        }
        
        return items[indexPath.row]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = items as? [[AnyObject]] {
            return sections.count
        }
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = items as? [[AnyObject]] {
            return sections[section].count
        }
        
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseIdentifier)
        
        assert(cell != nil, "No cell was registered with the reuse identifier: \(cellReuseIdentifier)")
        
        self.cellConfigurationHandler(cell: cell!, item: self.itemForIndexPath(indexPath)!)
        
        return cell!
    }
}