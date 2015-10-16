//
//  CollectionViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 29/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

@objc protocol Collectable {
    var title : String {get}
    var image : UIImage? {get}
    optional var subtitle: String {get}
}

class CollectionViewController: BaseViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var doneButton: UIBarButtonItem?
    
    var multipleSelection: Bool = false
    
    var completionHandler: (([Collectable])->Void)?
    
    var collectionViewDataSource: CollectionViewArrayDataSource = {
        return CollectionViewArrayDataSource(cellReuseIdentifier: "CollectableCell") {
            ($0 as! CollectableCell).collectable = $1 as? Collectable
        }
    }()
    
    var collectionData : [Collectable] {
        set {
            self.collectionViewDataSource.data = newValue
            self.collectionView?.reloadData()
        }
        get {
            return self.collectionViewDataSource.data as? [Collectable] ?? []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.dataSource = self.collectionViewDataSource
        self.collectionView?.delegate = self
        
        
        assert(self.collectionView != nil, "Collection view was not set for CollectionViewController")
        
        self.doneButton?.enabled = self.multipleSelection
    }
    
    func updateView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView?.reloadData()
        })
    }

//    MARK: Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !self.multipleSelection {
            self.completionHandler?([self.collectionViewDataSource.dataForIndexPath(indexPath) as! Collectable])
        }
    }
    
//    MARK: Actions
    
    @IBAction func cancel(sender: AnyObject) {
        self.completionHandler?([])
    }
    
    @IBAction func done(sender: AnyObject) {
        let selectedItems = self.collectionView!.indexPathsForSelectedItems()!.map({self.collectionData[$0.row]})
        completionHandler?(selectedItems)
    }
}
