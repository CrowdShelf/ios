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
        
        self.loadCrowds()
        
        self.completionHandler = {listable in
            self.performSegueWithIdentifier("ShowCrowdShelf", sender: listable)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadCrowds", name: CSDataHandlerNotification.LocalUserUpdated, object: nil)
    }
    
    func loadCrowds() {
        self.listData = CSUser.localUser != nil ? CSUser.localUser!.crowds : []
        self.updateView()
    }
    
}