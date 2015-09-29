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

class CollectionViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var doneButton: UIBarButtonItem?
    
    var multipleSelection: Bool = false
    
    var completionHandler: (([Collectable])->Void)?
    
    var collectionData : [Collectable] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        assert(self.collectionView != nil, "Collection view was not set for CollectionViewController")
        
        self.doneButton?.enabled = self.multipleSelection
    }
    
    func updateView() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView?.reloadData()
        })
    }
    
//    MARK: Collection View Data Source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectableCell", forIndexPath: indexPath) as! CollectableCell
        
        cell.collectable = self.collectionData[indexPath.row]
        
        return cell
    }
    
//    MARK: Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !self.multipleSelection {
            self.completionHandler?([self.collectionData[indexPath.row]])
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
