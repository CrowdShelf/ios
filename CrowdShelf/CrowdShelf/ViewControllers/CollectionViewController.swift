//
//  CollectionViewController.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 29/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

class CollectionViewController: BaseViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var doneButton: UIBarButtonItem?
    
    var multipleSelection: Bool = false
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    var completionHandler: (([Listable])->Void)?
    
    var collectionViewDataSource: CollectionViewArrayDataSource = {
        return CollectionViewArrayDataSource(cellReuseIdentifier: CollectableCell.cellReuseIdentifier) {
            ($0 as! CollectableCell).collectable = $1 as? Listable
        }
    }()
    
    var collectionData : [Listable] {
        set {
            self.collectionViewDataSource.data = newValue
            self.collectionView?.reloadData()
        }
        get {
            return self.collectionViewDataSource.data as? [Listable] ?? []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(self.collectionView != nil, "Collection view was not set for CollectionViewController")
        
        self.collectionView?.dataSource = self.collectionViewDataSource
        self.collectionView?.delegate = self
        
        self.collectionView?.registerCellForClass(CollectableCell)
        
        self.doneButton?.enabled = self.multipleSelection
        
        refreshControl.addTarget(self, action: "updateContent", forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
    }
    
    func updateContent() {
        refreshControl.endRefreshing()
    }
    
    func updateView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView?.reloadData()
        })
    }

//    MARK: Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !self.multipleSelection {
            self.completionHandler?([self.collectionViewDataSource.dataForIndexPath(indexPath) as! Listable])
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
