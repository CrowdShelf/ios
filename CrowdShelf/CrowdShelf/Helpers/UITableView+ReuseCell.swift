//
//  UITableView+ReuseCell.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 19/10/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit


extension UITableView {
    
    func registerCellForClass(cellClass: AnyClass) {
        
        if let validClass = cellClass as? UITableViewCell.Type {
            self.registerNib(UINib(nibName: validClass.cellReuseIdentifier, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: validClass.cellReuseIdentifier)
        } else {
            fatalError("\(cellClass) was not a valid UITableViewCell class")
        }
    }
    
}


extension UICollectionView {
    
    func registerCellForClass(cellClass: AnyClass) {
        if let validClass = cellClass as? UICollectionViewCell.Type {
            self.registerNib(UINib(nibName: validClass.cellReuseIdentifier, bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: validClass.cellReuseIdentifier)
        } else {
            fatalError("\(cellClass) was not a valid UICollectionViewCell class")
        }
    }
    
}

extension UICollectionViewCell {
    class var cellReuseIdentifier: String {
        /* Namespaces in swift makes the class name a key path. Use only the last component */
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}

extension UITableViewCell {
    class var cellReuseIdentifier: String {
        /* Namespaces in swift makes the class name a key path. Use only the last component */
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
}