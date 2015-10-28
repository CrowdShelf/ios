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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if collectionData.isEmpty {
            updateContent()
        }
    }
    
    override func updateContent() {
        refreshControl.beginRefreshing()
        
        self.collectionData = []
        
        var memberBooks: [String: [BookInformation]] = [:]

        for wrappedMemberID in self.crowd!.members {
            
            DataHandler.getTitleInformationForBooksWithParameters(["owner":wrappedMemberID.content], andCompletionHandler: { (titleInformation) -> Void in
                memberBooks[wrappedMemberID.stringValue!] = titleInformation
                self.collectionData = Set(memberBooks.values.flatMap {$0}).map {$0}
                self.collectionView?.reloadData()
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowBook", sender: self.collectionData[indexPath.row])
    }
}