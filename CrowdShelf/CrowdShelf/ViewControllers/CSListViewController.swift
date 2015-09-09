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
    optional var image : UIImage {get}
}

class CSListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    
    var tableViewCellStyle: UITableViewCellStyle = .Subtitle
    
    /// Called when user selects a row
    var completionHandler: ((Listable)->Void)?
    var listData : [Listable] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        assert(self.tableView != nil, "Table view was not set for CSListViewController")
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
        return self.listData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ListCell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: self.tableViewCellStyle, reuseIdentifier: "ListCell")
        }
        
        let listable = self.listData[indexPath.row]
        
        cell?.textLabel?.text = listable.title
        cell?.detailTextLabel?.text = listable.subtitle
        cell?.imageView?.image = listable.image
        
        return cell!
    }
    
//    MARK: - Table View Delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.completionHandler?(self.listData[indexPath.row])
    }
    
}