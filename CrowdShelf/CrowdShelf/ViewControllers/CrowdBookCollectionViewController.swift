//
//  CrowdBookCollectionViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 14/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class CrowdBookCollectionViewController: CollectionViewController {
    
    var crowd: Crowd? {
        didSet {
            self.title = crowd?.name
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadBooks()
    }
    
    func loadBooks() {
        self.collectionData = []
        
        let activityIndicatorView = ActivityIndicatorView.showActivityIndicatorWithMessage("Retrieving books", inView: self.view)
        
        for wrappedMemberID in self.crowd!.members {
            DataHandler.getBooksWithInformationWithParameters(["owner":wrappedMemberID.content], andCompletionHandler: { (books) -> Void in
                activityIndicatorView.stop()
                self.collectionData = self.collectionData + books
            })
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowBook", sender: self.collectionData[indexPath.row])
    }
}