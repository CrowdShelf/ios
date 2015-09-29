//
//  BookCollectionView.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 29/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class BookCollectionViewController: CollectionViewController {
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowBook", sender: self.collectionData[indexPath.row])
    }
    
    override func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}