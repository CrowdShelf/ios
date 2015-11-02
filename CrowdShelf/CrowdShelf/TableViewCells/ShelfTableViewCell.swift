//
//  ShelfTableViewCell.swift
//  CrowdShelf
//
//  Created by Øyvind Grimnes on 30/09/15.
//  Copyright © 2015 Øyvind Grimnes. All rights reserved.
//

import UIKit

protocol ShelfTableViewCellDelegate {
    func showAllBooksForShelfTableViewCell(shelfTableViewCell: ShelfTableViewCell)
    func shelfTableViewCell(shelfTableViewCell: ShelfTableViewCell, didSelectTitle title: BookInformation)
}

class ShelfTableViewCell: UITableViewCell, UICollectionViewDelegate {

    var shelf: Shelf? {
        didSet {
            self.updateView()
        }
    }
    
    var collectionViewDataSource: CollectionViewArrayDataSource?
    
    var delegate: ShelfTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var showAllButton: UIButton?
    
    override func awakeFromNib() {
        
        collectionView?.registerCellForClass(CollectableCell)
        
        self.collectionViewDataSource = CollectionViewArrayDataSource(cellReuseIdentifier: CollectableCell.cellReuseIdentifier) {
            ($0 as! CollectableCell).collectable = $1 as? Listable
        }
        
        self.collectionView!.dataSource = self.collectionViewDataSource
        self.collectionView!.delegate = self
        
        self.updateView()
    }
    
    private func updateView() {
        self.collectionViewDataSource?.data = self.shelf?.titles ?? []
        self.collectionView?.reloadData()
        
        self.titleLabel?.text = self.shelf?.name
        self.showAllButton?.hidden = self.shelf?.books.isEmpty ?? true
    }
    
//    MARK: Collection View Delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.shelfTableViewCell(self, didSelectTitle: self.collectionViewDataSource?.dataForIndexPath(indexPath) as! BookInformation)
    }
    
//    MARK: Actions
    
    @IBAction func showAll(sender: UIButton) {
        self.delegate?.showAllBooksForShelfTableViewCell(self)
    }
}
