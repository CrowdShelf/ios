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

class CSListViewController: CSBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var tableViewCellStyle: UITableViewCellStyle = .Subtitle
    
    /// Called when user selects a row
    var multipleSelection: Bool = false
    var completionHandler: (([Listable])->Void)?
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
        
        self.doneButton.enabled = self.multipleSelection
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ListCell")
                        ?? UITableViewCell(style: self.tableViewCellStyle, reuseIdentifier: "ListCell")
        
        let listable = self.listData[indexPath.row]
        
        cell.textLabel?.text = listable.title
        cell.detailTextLabel?.text = listable.subtitle
        cell.imageView?.image = listable.image!
        
        return cell
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