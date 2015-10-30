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
            cell.imageView?.showBorder = true
            cell.imageView?.borderColor
            cell.collectable = $1 as? Collectable
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if collectionData.isEmpty {
            updateContent()
        }
    }
    
    override func updateContent() {
        DataHandler.getCrowdsWithParameters(["member":User.localUser!._id]) { (crowds) -> Void in
            self.crowds = crowds
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowCrowd", sender: collectionView.cellForItemAtIndexPath(indexPath)!)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowCrowd" {
            let crowdVC = segue.destinationViewController as! CrowdViewController
            crowdVC.crowd = (sender as! CollectableCell).collectable as? Crowd
        }
    }
}
