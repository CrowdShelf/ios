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
            if crowd != nil {
                self.books = crowd!.members.flatMap {$0.books}
            } else {
                self.books = []
            }
            self.collectionView?.reloadData()
        }
    }
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}