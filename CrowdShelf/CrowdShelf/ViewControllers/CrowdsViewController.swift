//
//  CrowdsViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 13/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit
import RealmSwift

class CrowdsViewController: CollectionViewController {
    
    var crowds: [Crowd] = [] {
        didSet {
            self.collectionData = crowds
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.completionHandler = {
            csprint(CS_DEBUG_CROWDS_VIEW, "Selected:  \($0)")
        }
        
        self.collectionViewDataSource?.configurationHandler = {
            let cell = $0 as! CollectableCell
            cell.imageViewStyle = .Round
            cell.collectable = $1 as? Collectable
        }
        
        DataHandler.getCrowdsWithParameters(nil) { (crowds) -> Void in
            self.collectionData = crowds
            self.collectionView?.reloadData()
        }
    }
    
}
