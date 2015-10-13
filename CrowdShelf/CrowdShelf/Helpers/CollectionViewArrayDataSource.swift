//
//  CollectionViewArrayDataSource.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 13/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewArrayDataSource: NSObject, UICollectionViewDataSource {
    
    typealias CellConfigurationClosure = ((UICollectionViewCell, AnyObject)->Void)

    var data: [AnyObject]
    
    var cellReuseIdentifier: String
    var configurationHandler: CellConfigurationClosure
    
    init(data: [AnyObject] = [], cellReuseIdentifier: String, configurationHandler: CellConfigurationClosure) {
        self.cellReuseIdentifier = cellReuseIdentifier
        self.configurationHandler = configurationHandler
        self.data = data
    }
    
    func dataForIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if let sections = self.data as? [[AnyObject]] {
            return sections[indexPath.section][indexPath.row]
        }
        return self.data[indexPath.row]
    }
    
//    MARK: - Collection View Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let sections = self.data as? [[AnyObject]] {
            return sections.count
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = self.data as? [[AnyObject]] {
            return sections[section].count
        }
        return self.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellReuseIdentifier, forIndexPath: indexPath)
        self.configurationHandler(cell, self.dataForIndexPath(indexPath)!)
        return cell
    }
}