//
//  CSCrowdShelfViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 02/09/15.
//  Copyright (c) 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation


class CSCrowdShelfViewController: CSShelfViewController {
    
    var crowd: CSCrowd? {
        didSet {
            self.books = []
            self.collectionView?.reloadData()
            
            for member in crowd!.members {
                CSDataHandler.getUser(member, withCompletionHandler: { (user) -> Void in
                    self.books.extend(user!.booksOwned)
                    
                    self.collectionView?.reloadData()
                })
            }
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}