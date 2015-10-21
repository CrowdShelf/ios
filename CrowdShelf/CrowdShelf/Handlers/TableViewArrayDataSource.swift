//
//  TableViewArrayDataSource.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 13/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class TableViewArrayDataSource: NSObject, UITableViewDataSource {
    
    typealias CellConfigurationHandler = ((cell: UITableViewCell, item: AnyObject, indexPath: NSIndexPath) -> Void)
    
    var items: [AnyObject]
    var cellReuseIdentifier: String
    var cellConfigurationHandler: CellConfigurationHandler
    var sectionTitles: [String?] = []
    
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
    
    func addItem(item: AnyObject, forIndexPath indexPath: NSIndexPath) {
        if let existingItems = self.items[indexPath.section] as? [AnyObject] {
            var updatedItems = existingItems
            updatedItems.insert(item, atIndex: indexPath.row)
            self.items[indexPath.section] = updatedItems
        } else {
            self.items.insert(items, atIndex: indexPath.row)
        }
    }
    
    func removeItemForIndexPath(indexPath: NSIndexPath) {
        if let existingItems = self.items[indexPath.section] as? [AnyObject] {
            var updatedItems = existingItems
            updatedItems.removeAtIndex(indexPath.row)
            self.items[indexPath.section] = updatedItems
        } else {
            self.items.removeAtIndex(indexPath.row)
        }
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
        
        self.cellConfigurationHandler(cell: cell!, item: self.itemForIndexPath(indexPath)!, indexPath: indexPath)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section > 0 && section < sectionTitles.count ? sectionTitles[section] : nil
    }
}