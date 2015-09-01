//
//  CSCrowdsViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 01/09/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class CSCrowdsViewController: CSListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cellStyle = .Subtitle
        self.completionHandler = {crowd in
            println(crowd)
        }
        
        self.listData = [CSCrowd(name: "My crowd")]
        self.tableView?.reloadData()
    }
    
}