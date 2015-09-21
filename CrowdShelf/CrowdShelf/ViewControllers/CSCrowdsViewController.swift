//
//  CSCrowdsViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 01/09/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


class CSCrowdsViewController: CSListViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tableViewCellStyle = .Subtitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadCrowds()
        
        self.completionHandler = {listable in
            self.performSegueWithIdentifier("ShowCrowdShelf", sender: listable)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadCrowds", name: CSNotification.LocalUserUpdated, object: nil)
    }
    
    func loadCrowds() {
//        CSDataHandler.getCrowdsWithCompletionHandler { (crowds) -> Void in
//            self.listData = crowds
//            self.updateView()
//        }
    }
    
}