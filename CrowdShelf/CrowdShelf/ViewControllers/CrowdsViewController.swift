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
    
    var crowds: [Crowd] {
        set {
            self.collectionData = newValue
        }
        get {
            return self.collectionData as? [Crowd] ?? []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionViewDataSource.configurationHandler = {
            let cell = $0 as! CollectableCell
            cell.imageViewStyle = .Round
            cell.collectable = $1 as? Collectable
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        DataHandler.getCrowdsWithParameters(nil) { (crowds) -> Void in
            self.crowds = crowds
            self.collectionView?.reloadData()
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCrowdBookCollection" {
            let crowdBookCollectionVC = segue.destinationViewController as! CrowdBookCollectionViewController
            crowdBookCollectionVC.crowd = (sender as! CollectableCell).collectable as! Crowd
        }
    }
}
